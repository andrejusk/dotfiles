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
mkdir -p "$HOME/.local/bin"

# workspace
# -----------------------------------------------------------------
export WORKSPACE=${WORKSPACE:-"$HOME/Workspace"}
mkdir -p "$WORKSPACE"

# dotfiles
# -----------------------------------------------------------------
export DOTFILES=${DOTFILES:-"$HOME/.dotfiles"}

# Node configuration (lazy loaded in .zshrc)
# -----------------------------------------------------------------
export NVM_DIR=${NVM_DIR:-"$HOME/.config/nvm"}
mkdir -p "$NVM_DIR"

# Add default node to PATH (no NVM init required)
node_alias="$NVM_DIR/alias/lts/jod"
if [ -f "$node_alias" ]; then
    VERSION=$(cat "$node_alias")
    node_bin_path="$NVM_DIR/versions/node/$VERSION/bin"
    if [[ ":$PATH:" != *":$node_bin_path:"* ]]; then
        export PATH="$node_bin_path:$PATH"
    fi
fi
unset node_alias VERSION node_bin_path

# Python configuration (lazy loaded in .zshrc)
# -----------------------------------------------------------------
export PYENV_ROOT=${PYENV_ROOT:-"$HOME/.pyenv"}
if [[ ":$PATH:" != *":$PYENV_ROOT/bin:"* ]]; then
    export PATH="$PYENV_ROOT/bin:$PATH"
fi
# Add pyenv shims to PATH (no init required)
if [[ ":$PATH:" != *":$PYENV_ROOT/shims:"* ]]; then
    export PATH="$PYENV_ROOT/shims:$PATH"
fi

export POETRY_ROOT=${POETRY_ROOT:-"$HOME/.poetry"}
if [[ ":$PATH:" != *":$POETRY_ROOT/bin:"* ]]; then
    export PATH="$POETRY_ROOT/bin:$PATH"
fi

# aliases
# -----------------------------------------------------------------
if [ -f ~/.aliases ]; then
    source ~/.aliases
fi

# Homebrew configuration (lazy loaded in .zshrc)
# -----------------------------------------------------------------------------
export HOMEBREW_NO_ANALYTICS=1
if [[ ":$PATH:" != *":/opt/homebrew/bin:"* ]]; then
    [ -x "/opt/homebrew/bin/brew" ] && export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
fi
