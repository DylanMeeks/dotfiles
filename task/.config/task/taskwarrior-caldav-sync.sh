#!/bin/bash

# Taskwarrior ↔ CalDAV Multi-Calendar Sync Script
# Supports multiple calendars with tag/project associations

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
SCRIPT_NAME=$(basename "$0")
CONFIG_DIR="$HOME/.config/task/taskwarrior-caldav-sync"
CONFIG_FILE="$CONFIG_DIR/config.env"
CALENDAR_CONFIG="$CONFIG_DIR/calendars.conf"
LOG_FILE="$CONFIG_DIR/sync.log"

# Ensure config directory exists
mkdir -p "$CONFIG_DIR"

# Logging functions
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    log "ERROR: $1"
    exit 1
}

info() {
    echo -e "${GREEN}$1${NC}"
    log "INFO: $1"
}

warning() {
    echo -e "${YELLOW}Warning: $1${NC}"
    log "WARN: $1"
}

# Check dependencies
check_dependencies() {
    local deps=("bw" "tw_caldav_sync" "task" "jq")
    local missing=()

    for cmd in "${deps[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done

    if [ ${#missing[@]} -ne 0 ]; then
        error_exit "Missing dependencies: ${missing[*]}\nPlease install: bitwarden-cli, syncall[caldav,tw], taskwarrior, jq"
    fi
}

# Check Bitwarden login status
check_bitwarden_auth() {
    if ! bw status | grep -q "unlocked"; then
        warning "Bitwarden vault is locked or not logged in"

        if command -v bw unlock &> /dev/null; then
            echo "Please unlock your Bitwarden vault:"
            bw unlock
        else
            echo "Please login to Bitwarden:"
            bw login
        fi

        if ! bw status | grep -q "unlocked"; then
            error_exit "Failed to authenticate with Bitwarden"
        fi
    fi
}

# Get password from Bitwarden
get_password() {
    local username="$1"
    local item_name="baikal-$username"

    local item_id
    item_id=$(bw list items --search "$item_name" | jq -r '.[0].id // empty')

    if [ -z "$item_id" ]; then
        warning "CalDAV password not found in Bitwarden"
        echo "Please enter your CalDAV password (it will be stored securely in Bitwarden):"
        read -rs -p "Password: " password
        echo

        local json_data
        json_data=$(jq -n \
                --arg name "$item_name" \
                --arg username "$username" \
                --arg password "$password" \
                --arg url "$CALDAV_URL" \
                '{
                name: $name,
                type: 1,
                login: {
                    username: $username,
                    password: $password,
                    uris: [{ uri: $url }]
                }
        }')

        item_id=$(echo "$json_data" | bw encode | bw create item | jq -r '.id')

        if [ -z "$item_id" ]; then
            error_exit "Failed to store password in Bitwarden"
        fi

        info "Password stored in Bitwarden as '$item_name'"
    fi

    bw get password "$item_id"
}

# Load or create main configuration
load_main_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    else
        echo "Creating main configuration..."

        read -p "CalDAV URL (e.g., https://nextcloud.example.com/remote.php/dav): " CALDAV_URL
        read -p "CalDAV Username: " CALDAV_USER

        if [[ ! "$CALDAV_URL" =~ ^https?:// ]]; then
            error_exit "Invalid CalDAV URL format"
        fi

        cat > "$CONFIG_FILE" << EOF
# Taskwarrior-Caldav Sync Configuration
CALDAV_URL="$CALDAV_URL"
CALDAV_USER="$CALDAV_USER"
EOF

        chmod 600 "$CONFIG_FILE"
        info "Main configuration saved to $CONFIG_FILE"
    fi

    export CALDAV_URL CALDAV_USER
}

# Manage calendar configurations
manage_calendars() {
    if [ ! -f "$CALENDAR_CONFIG" ]; then
        echo "No calendar configurations found. Creating initial setup..."
        create_calendar_config
    fi

    echo -e "\n${BLUE}Current Calendar Configurations:${NC}"
    echo "================================"

    local index=1
    while IFS='|' read -r calendar_name tags projects; do
        echo "$index. Calendar: $calendar_name"
        echo "   Tags: ${tags:-(none)}"
        echo "   Projects: ${projects:-(none)}"
        echo
        ((index++))
    done < "$CALENDAR_CONFIG"
}

# Create new calendar configuration
create_calendar_config() {
    echo "Creating calendar configurations..."

    > "$CALENDAR_CONFIG"

    while true; do
        echo -e "\n${BLUE}Add Calendar Configuration${NC}"
        read -p "Calendar name (or 'done' to finish): " calendar_name

        [ "$calendar_name" = "done" ] && break

        if [ -z "$calendar_name" ]; then
            warning "Calendar name cannot be empty"
            continue
        fi

        read -p "Associated tags (comma-separated, e.g., work,urgent): " tags
        read -p "Associated projects (comma-separated, e.g., work.personal,work.team): " projects

        # Clean up inputs
        tags=$(echo "$tags" | sed 's/[[:space:]]//g')
        projects=$(echo "$projects" | sed 's/[[:space:]]//g')

        echo "$calendar_name|$tags|$projects" >> "$CALENDAR_CONFIG"
        info "Added calendar: $calendar_name"
    done

    chmod 600 "$CALENDAR_CONFIG"
}

# Edit calendar configurations
edit_calendars() {
    if [ -f "$CALENDAR_CONFIG" ]; then
        echo "Opening calendar configuration in editor..."
        ${EDITOR:-nano} "$CALENDAR_CONFIG"
    else
        create_calendar_config
    fi
}

# Sync individual calendar
sync_calendar() {
    local calendar_name="$1"
    local tags="$2"
    local projects="$3"

    info "Syncing calendar: $calendar_name"

    # Check Bitwarden authentication
    check_bitwarden_auth

    # Get password from Bitwarden
    local password
    password=$(get_password "$CALDAV_USER")

    if [ -z "$password" ]; then
        error_exit "Failed to retrieve password from Bitwarden"
    fi

    # Build sync command
    local cmd=(
        tw_caldav_sync
        --caldav-url "$CALDAV_URL"
        --caldav-user "$CALDAV_USER"
        --caldav-passwd "$password"
        --calendar "$calendar_name"
    )

    # Add tags filter
    if [ -n "$tags" ]; then
        IFS=',' read -ra TAGS <<< "$tags"
        for tag in "${TAGS[@]}"; do
            [ -n "$tag" ] && cmd+=(--taskwarrior-tags "$tag")
        done
    fi

    # Add projects filter
    if [ -n "$projects" ]; then
        IFS=',' read -ra PROJECTS <<< "$projects"
        for project in "${PROJECTS[@]}"; do
            [ -n "$project" ] && cmd+=(--taskwarrior-project "$project")
        done
    fi

    # Execute sync
    info "Executing: ${cmd[*]}"
    if "${cmd[@]}"; then
        info "Sync completed for calendar: $calendar_name"
    else
        warning "Sync failed for calendar: $calendar_name"
    fi
}

# Sync all calendars
sync_all_calendars() {
    info "Starting sync for all calendars..."

    local success_count=0
    local total_count=0

    while IFS='|' read -r calendar_name tags projects; do
        [ -z "$calendar_name" ] && continue

        ((total_count++))
        if sync_calendar "$calendar_name" "$tags" "$projects"; then
            ((success_count++))
        fi

        echo "----------------------------------------"
    done < "$CALENDAR_CONFIG"

    info "Sync completed: $success_count/$total_count calendars synced successfully"
}

# Interactive calendar selection
sync_selected_calendars() {
    if [ ! -f "$CALENDAR_CONFIG" ]; then
        error_exit "No calendar configurations found. Run --setup-calendars first."
    fi

    local calendars=()
    local index=1

    echo -e "\n${BLUE}Select calendars to sync:${NC}"
    while IFS='|' read -r calendar_name tags projects; do
        [ -z "$calendar_name" ] && continue
        echo "$index. $calendar_name"
        calendars+=("$calendar_name|$tags|$projects")
        ((index++))
    done < "$CALENDAR_CONFIG"

    echo -e "\nEnter numbers to sync (comma-separated, or 'all'): "
    read -p "Selection: " selection

    if [ "$selection" = "all" ]; then
        sync_all_calendars
    else
        IFS=',' read -ra selections <<< "$selection"
        for sel in "${selections[@]}"; do
            sel=$(echo "$sel" | tr -d ' ')
            if [[ "$sel" =~ ^[0-9]+$ ]] && [ "$sel" -ge 1 ] && [ "$sel" -le ${#calendars[@]} ]; then
                IFS='|' read -r calendar_name tags projects <<< "${calendars[$((sel-1))]}"
                sync_calendar "$calendar_name" "$tags" "$projects"
            else
                warning "Invalid selection: $sel"
            fi
        done
    fi
}

# Show usage
usage() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Options:
    -h, --help              Show this help message
    -c, --config            Show current configuration
    -s, --setup-calendars   Setup calendar configurations
    -e, --edit-calendars    Edit calendar configurations
    -l, --list-calendars    List all calendar configurations
    -a, --sync-all          Sync all calendars
    -i, --interactive       Interactive calendar selection

Examples:
    $SCRIPT_NAME                    # Interactive calendar selection
    $SCRIPT_NAME --sync-all         # Sync all calendars
    $SCRIPT_NAME --setup-calendars # Configure calendars
    $SCRIPT_NAME --list-calendars  # List configurations

Configuration files:
    Main config: $CONFIG_FILE
    Calendar config: $CALENDAR_CONFIG
    Log file: $LOG_FILE
EOF
}

# Main execution
main() {
    case "${1:-}" in
        -h|--help)
            usage
            ;;
        -c|--config)
            echo "Main Configuration:"
            [ -f "$CONFIG_FILE" ] && cat "$CONFIG_FILE" || echo "No main config found"
            echo
            manage_calendars
            ;;
        -s|--setup-calendars)
            check_dependencies
            load_main_config
            create_calendar_config
            ;;
        -e|--edit-calendars)
            check_dependencies
            edit_calendars
            ;;
        -l|--list-calendars)
            check_dependencies
            manage_calendars
            ;;
        -a|--sync-all)
            check_dependencies
            load_main_config
            sync_all_calendars
            ;;
        -i|--interactive)
            check_dependencies
            load_main_config
            sync_selected_calendars
            ;;
        "")
            check_dependencies
            load_main_config
            sync_selected_calendars
            ;;
        *)
            error_exit "Unknown option: $1\nUse --help for usage information"
            ;;
    esac
}

# Run main function
main "$@"
