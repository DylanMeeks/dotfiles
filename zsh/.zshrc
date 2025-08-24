# Autostart Hyprland at Login
if [ -z "${WAYLAND_DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
    exec Hyprland
fi

alias lock='swaylock'

alias ff='fastfetch'
alias za='zathura'

# Colored output
alias ls='ls -laGH --color=auto'
alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias ip='ip --color=auto'

# Multiplexer
alias mx="zellij --layout $HOME/.config/zellij/layout.kdl"

# Colored pagers
export LESS='-R --use-color -Dd+r$Du+b'
export MANPAGER='nvim +Man!'

# Setting Default Editor
export EDITOR='nvim'
export VISUAL='nvim'

# File to store ZSH history
export HISTFILE=~/.zsh_history

# Number of commands loaded into memory from HISTFILE
export HISTSIZE=1000

# Maximum number of commands stores in HISTFILE
export SAVEHIST=1000

# Loading ZSH modules
autoload -Uz compinit
autoload -Uz vcs_info # Git

# # Style control for completion system and VCS
# # zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
# # zstyle ':completion:*' menu select
# # zstyle ':completion::complete:*' gain-privileges 1
# # zstyle ':completion:*' rehash true                      # Rehash so compinit can automatically find new executables in $PATH
# # zstyle ':vcs_info:*' enable git
# # zstyle ':vcs_info:git:*' formats 'on %F{red} %b%f '    # Set up Git Branch details into prompt
# #
# # disable sort when completing `git checkout`
# zstyle ':completion:*:git-checkout:*' sort false
# # set descriptions format to enable group support
# # NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
# zstyle ':completion:*:descriptions' format '[%d]'
# # set list-colors to enable filename colorizing
# zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# # force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
# zstyle ':completion:*' menu no
# # preview directory's content with eza when completing cd
# zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# # custom fzf flags
# # NOTE: fzf-tab does not follow FZF_DEFAULT_OPTS by default
# zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
# # To make fzf-tab follow FZF_DEFAULT_OPTS.
# # NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
# zstyle ':fzf-tab:*' use-fzf-default-opts yes
# # switch group using `<` and `>`
# zstyle ':fzf-tab:*' switch-group '<' '>'


# Match dotfiles without explicitly specifying the dot
compinit
_comp_options+=(globdots)

export PATH=$PATH:~/go/bin/

# carapace auto-completion
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
export CARAPACE_MATCH=1 # case insensitive
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
source <(carapace _carapace)
zstyle ':completion:*:git:*' group-order 'main commands' 'alias commands' 'external commands'

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

source <(COMPLETE=zsh jj)

# ZSH completions
fpath=(~/.zsh/zsh-completions/src $fpath)

# Rust setup
export PATH=$PATH:~/.cargo/bin/
. $HOME/.cargo/env

export PATH=$PATH:/usr/local/go/bin

export PATH=/home/dylanm/.nimble/bin:$PATH

# ZVM
export ZVM_INSTALL="$HOME/.zvm/self"
export PATH="$PATH:$HOME/.zvm/bin"
export PATH="$PATH:$ZVM_INSTALL/"

export PATH=$PATH:~/.local/bin/

# ZSH Syntax Highlighting - must be at the end of .zshrc!
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

. "$HOME/.local/bin/env"

# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
[[ ! -r '/home/dylanm/.opam/opam-init/init.zsh' ]] || source '/home/dylanm/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null
# END opam configuration

export GPG_TTY=$(tty)


# pnpm
export PNPM_HOME="/home/dylanm/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Prevent blinking cursor.
function __set_beam_cursor {
    echo -ne '\e[6 q'
}

function __set_block_cursor {
    echo -ne '\e[2 q'
}

function zle-keymap-select {
  case $KEYMAP in
    vicmd) __set_block_cursor;;
    viins|main) __set_beam_cursor;;
  esac
}
zle -N zle-keymap-select

precmd_functions+=(__set_block_cursor)


eval "$(zoxide init zsh)"
