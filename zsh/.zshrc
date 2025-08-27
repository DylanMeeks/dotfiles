# autostart sway
[ "$(tty)" = "/dev/tty1" ] && exec sway

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

setopt inc_append_history
setopt HIST_SAVE_NO_DUPS

alias ls='las --color=auto -HGv'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'

alias lock="swaylock"
alias za="zathura"
alias ff="fastfetch"

export LESS='-R --use-color -Dd+r$Du+b'
export MANPAGER='nvim +Man!'

export EDITOR='nvim'
export VISUAL='nvim'

# PATH extensions
# local bin
export PATH=$PATH:~/.local/bin/
# rust
export PATH=$PATH:~/.cargo/bin/
. $HOME/.cargo/env

# go
export PATH=$PATH:~/go/bin/
export PATH=$PATH:/usr/local/go/bin/

# Block cursor
cursor_mode() {
function __set_block_cursor {
    echo -ne '\e[2 q'
}
function __set_beam_cursor {
    echo -ne '\e[6 q'
}
function zle-keymap-select {
    case $KEYMAP in
        vimcmd) __set_beam_cursor;;
        viins|main) __set_block_cursor;;
    esac
}
function zle-line-init {
    __set_block_cursor
}
zle -N zle-keymap-select
zle -N zle-line-init
}

cursor_mode

# Vim keybinds
bindkey -v
# export KEYTIMEOUT=1

zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line # v in normal mode to use EDITOR to edit command

autoload -Uz select-bracketed select-quoted
zle -N select-quoted
zle -N select-bracketed
for km in viopp visual; do
  bindkey -M $km -- '-' vi-up-line-or-history
  for c in {a,i}${(s..)^:-\'\"\`\|,./:;=+@}; do
    bindkey -M $km $c select-quoted
  done
  for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
    bindkey -M $km $c select-bracketed
  done
done

# Plugins and Integrations
fpath=("$HOME/.zsh/zsh-completions/src" $fpath)
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/fzf-zsh-plugin/fzf-zsh-plugin.plugin.zsh

source <(fzf --zsh)
eval "$(zoxide init zsh)"

# "lazy load" jj completion to speed up startup
jj() {
    if [ -z "$JJ_LOADED" ]; then
        source <(command jj util completion zsh)
        JJ_LOADED=true
    fi
    command jj "$@"
}

source ~/.zsh/geometry/geometry.zsh
GEOMETRY_STATUS_COLOR_ERROR="red"      # prompt symbol color when exit value is != 0
GEOMETRY_STATUS_COLOR="default"        # prompt symbol color
GEOMETRY_STATUS_COLOR_ROOT="red"       # root prompt symbol color
GEOMETRY_EXITCODE_COLOR="red"          # exit code color
GEOMETRY_GIT_SYMBOL_REBASE="\uE0A0"    # set the default rebase symbol to the powerline symbol î 
GEOMETRY_GIT_SYMBOL_STASHES=x          # change the git stash indicator to `x`
GEOMETRY_GIT_COLOR_STASHES=blue        # change the git stash color to blue
GEOMETRY_GIT_NO_COMMITS_MESSAGE=""     # hide the 'no commits' message in new repositories

autoload -Uz compinit
autoload -Uz vcs_info
compinit
_comp_options+=(globdots)

# this must go last
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

