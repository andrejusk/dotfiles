# xdg data & config
# -----------------------------------------------------------------
export XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME/.local/share"}
mkdir -p "$XDG_DATA_HOME"
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}
mkdir -p "$XDG_CONFIG_HOME"

# local user binaries
# -----------------------------------------------------------------
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi
mkdir -p $HOME/.local/bin

# workspace
# -----------------------------------------------------------------
export WORKSPACE=${WORKSPACE:-"$HOME/Workspace"}
mkdir -p "$WORKSPACE"

# dotfiles
# -----------------------------------------------------------------
export DOTFILES=${DOTFILES:-"$HOME/.dotfiles"}

# nvm
# -----------------------------------------------------------------
if [ -z "$NVM_DIR" ]; then
    export NVM_DIR=${NVM_DIR:-"$HOME/.nvm"}
    mkdir -p "$NVM_DIR"
fi

# pyenv
# -----------------------------------------------------------------
export PYENV_ROOT=${PYENV_ROOT:-"$HOME/.pyenv"}
if [[ ":$PATH:" != *":$PYENV_ROOT/bin:"* ]]; then
    export PATH="$PYENV_ROOT/bin:$PATH"
fi

# poetry
# -----------------------------------------------------------------
export POETRY_ROOT=${POETRY_ROOT:-"$HOME/.poetry"}
if [[ ":$PATH:" != *":$POETRY_ROOT/bin:"* ]]; then
    export PATH="$POETRY_ROOT/bin:$PATH"
fi

# aliases
# -----------------------------------------------------------------
if [ -f ~/.aliases ]; then
  source ~/.aliases
fi
