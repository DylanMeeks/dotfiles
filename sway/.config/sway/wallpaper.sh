#!/usr/bin/env bash
set -euo pipefail

BACKGROUNDS_DIR="$HOME/Documents/wallpapers"

if [ ! -d "$BACKGROUNDS_DIR" ]; then
    echo "Error: Backgrounds directory '$BACKGROUNDS_DIR' not found." >&2
    exit 1
fi

# Pick a random image robustly (handles spaces/newlines)
RANDOM_BACKGROUND="$(
    find "$BACKGROUNDS_DIR" -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' \) \
        -print0 \
        | shuf -z -n 1 \
        | xargs -0 -I{} printf '%s' "{}"
)"

if [ -z "$RANDOM_BACKGROUND" ]; then
    echo "Error: No suitable background images found in '$BACKGROUNDS_DIR'." >&2
    exit 1
fi

# Kill any existing swaybg instances for a clean restart
pkill -x swaybg 2>/dev/null || true

# Small delay to ensure old one exits
sleep 0.1

# Start new swaybg in the background; disown so it doesn't die with the script
swaybg -i "$RANDOM_BACKGROUND" -m fill &
disown
