# U _____ u _   _  __     __
# \| ___"|/| \ |"| \ \   /"/u
#  |  _|" <|  \| |> \ \ / //
#  | |___ U| |\  |u /\ V /_,-.
#  |_____| |_| \_| U  \_/-(_/
#  <<   >> ||   \\,-.//
# (__) (__)(_")  (_/(__)
#
# set PATH so it includes user's private bin
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# xdg data & config
if [ -z "$XDG_DATA_HOME" ]; then
    export XDG_DATA_HOME="$HOME/.local/share"
fi
mkdir -p "$XDG_DATA_HOME"
if [ -z "$XDG_CONFIG_HOME" ]; then
    export XDG_CONFIG_HOME="$HOME/.config"
fi
mkdir -p "$XDG_CONFIG_HOME"

# workspace
if [ -z "$WORKSPACE" ]; then
    export WORKSPACE="$HOME/workspace"
fi
mkdir -p "$WORKSPACE"

# dotfiles
if [ -z "$DOTFILES" ]; then
    export DOTFILES="$HOME/.dotfiles"
fi

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="$PYENV_ROOT/shims:$PATH"
if [ -d "$PYENV_ROOT" ]; then
    [ -x "$(command -v pyenv)" ] && eval "$(pyenv init -)"
fi

# poetry
export POETRY_ROOT="$HOME/.poetry"
export PATH="$POETRY_ROOT/bin:$PATH"

# nvm
if [ -z "$NVM_DIR" ]; then
export NVM_DIR="$HOME/.nvm"
fi
mkdir -p "$NVM_DIR"
export PATH="$NVM_DIR/bin:$PATH"

# yarn
export YARN_DIR="$HOME/.yarn"
mkdir -p "$YARN_DIR"
export PATH="$YARN_DIR/bin:$PATH"

# editor
export EDITOR="nvim"
export VISUAL="nvim"

# fzf
export FZF_DEFAULT_OPTS="--reverse"
export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_COMPLETION_TRIGGER='**'

# do not use fishlogin for subshells
export SHELL=/bin/sh

 #    _       _                    _      ____
# U  /"\  u  |"|        ___    U  /"\  u / __"| u
#  \/ _ \/ U | | u     |_"_|    \/ _ \/ <\___ \/
#  / ___ \  \| |/__     | |     / ___ \  u___) |
# /_/   \_\  |_____|  U/| |\u  /_/   \_\ |____/>>
#  \\    >>  //  \\.-,_|___|_,-.\\    >>  )(  (__)
# (__)  (__)(_")("_)\_)-' '-(_/(__)  (__)(__)
#
alias vim='nvim'
alias vi='vim'

alias bat='batcat'
alias cat='bat'

alias j="z"
