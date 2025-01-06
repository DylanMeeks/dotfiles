#
# ███████╗███████╗██╗  ██╗██████╗  ██████╗
# ╚══███╔╝██╔════╝██║  ██║██╔══██╗██╔════╝
#   ███╔╝ ███████╗███████║██████╔╝██║
#  ███╔╝  ╚════██║██╔══██║██╔══██╗██║
# ███████╗███████║██║  ██║██║  ██║╚██████╗
# ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝
#
# ZSH Config File by Arfan Zubi


# Autostart Hyprland at Login
if [ -z "${WAYLAND_DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
    exec Hyprland
fi

# Aliases
# alias q='exit'
# alias ..='cd ..'
# alias ls='exa -l -F --icons --hyperlink'
# alias l='ls -l'
# alias la='ls -a'
# alias lla='ls -la'
# alias t='tree'
# alias rm='rm -v'
# alias open='xdg-open'

alias v='nvim'
alias vi='nvim'
alias vim='nvim'
# alias nv='neovide'

alias gs='git status'
alias ga='git add -A'
alias gc='git commit'
alias gpll='git pull'
alias gpsh='git push'
alias gd='git diff'
alias gl='git log --stat --graph --decorate --oneline'

alias lock='swaylock'
alias standby='systemctl suspend'

alias ff='fastfetch'
alias b='bat'
alias rr='ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR"'
alias z='zathura'

# Colored output
alias ls='ls -laGH --color=auto'
alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias ip='ip --color=auto'

# Colored pagers
export LESS='-R --use-color -Dd+r$Du+b'
export MANPAGER='less -R --use-color -Dd+r -Du+b'
#export MANPAGER="sh -c 'col -bx | bat -l man -p'"
# export BAT_THEME='Catppuccin Latte'

# Setting Default Editor
export EDITOR='nvim'
export VISUAL='nvim'

# File to store ZSH history
export HISTFILE=~/.zsh_history

# Number of commands loaded into memory from HISTFILE
export HISTSIZE=1000

# Maximum number of commands stores in HISTFILE
export SAVEHIST=1000

# Setting default Ranger RC to false to avoid loading it twice
export RANGER_LOAD_DEFAULT_RC='false'

# Loading ZSH modules
autoload -Uz compinit
autoload -Uz vcs_info # Git

# Style control for completion system and VCS
# zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
# zstyle ':completion:*' menu select
# zstyle ':completion::complete:*' gain-privileges 1
# zstyle ':completion:*' rehash true                      # Rehash so compinit can automatically find new executables in $PATH
# zstyle ':vcs_info:*' enable git
# zstyle ':vcs_info:git:*' formats 'on %F{red} %b%f '    # Set up Git Branch details into prompt
#
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# custom fzf flags
# NOTE: fzf-tab does not follow FZF_DEFAULT_OPTS by default
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
# To make fzf-tab follow FZF_DEFAULT_OPTS.
# NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'

# Match dotfiles without explicitly specifying the dot
compinit
_comp_options+=(globdots)

# Load Version Control System into prompt
precmd() { vcs_info }

# Prompt Appearance
setopt PROMPT_SUBST

# PS1='%B%F{blue}❬%n%f@%F{blue}%m❭%f %F{blue} %1~%f%b ${vcs_info_msg_0_} '
source ~/.zsh/geometry/geometry.zsh

# ZSH profile
# source ~/.profile

# XDG user dirs
# source ~/.config/user-dirs.dirs

# Keybindings for FZF
source /usr/share/fzf/shell/key-bindings.zsh
# source /usr/share/fzf/completion.zsh

# FZF zsh plugin
source ~/.zsh/fzf-zsh-plugin/fzf-zsh-plugin.plugin.zsh

# FZF-tab
source ~/.zsh/fzf-tab/fzf-tab.plugin.zsh

# ZSH Autosuggestions
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

source <(fzf --zsh)

# ZSH completions
fpath=(~/.zsh/zsh-completions/src $fpath)

export PATH=$PATH:~/.cargo/bin/

export PATH=$PATH:~/go/bin/

export PATH=$PATH:~/.local/bin/

# ZSH Syntax Highlighting - must be at the end of .zshrc!
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
