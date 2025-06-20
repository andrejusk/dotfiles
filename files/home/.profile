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

# Initialise and load Node
# -----------------------------------------------------------------
if [ -z "$NVM_DIR" ]; then
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    mkdir -p "$NVM_DIR"
fi

_dots_load_nvm() {
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}
_dots_load_nvm

node_alias="$NVM_DIR/alias/lts/jod"
if [ -f "$node_alias" ]; then
    VERSION=$(cat "$node_alias")
    node_bin_path="$NVM_DIR/versions/node/$VERSION/bin"
    if [[ ":$PATH:" != *":$node_bin_path:"* ]]; then
        export PATH="$node_bin_path:$PATH"
    fi
fi
unset node_alias VERSION node_bin_path

# Initialise and load Python
# -----------------------------------------------------------------
export PYENV_ROOT=${PYENV_ROOT:-"$HOME/.pyenv"}
if [[ ":$PATH:" != *":$PYENV_ROOT/bin:"* ]]; then
    export PATH="$PYENV_ROOT/bin:$PATH"
fi
_dots_load_pyenv() {
    [ -x $(command -v pyenv) ] && eval "$(pyenv init --path)"
}
_dots_load_pyenv

export POETRY_ROOT=${POETRY_ROOT:-"$HOME/.poetry"}
if [[ ":$PATH:" != *":$POETRY_ROOT/bin:"* ]]; then
    export PATH="$POETRY_ROOT/bin:$PATH"
fi

# aliases
# -----------------------------------------------------------------
if [ -f ~/.aliases ]; then
    source ~/.aliases
fi

# Load homebrew
# -----------------------------------------------------------------------------
_dots_load_brew() {
    export HOMEBREW_NO_ANALYTICS=1
    [ -x "/opt/homebrew/bin/brew" ] && eval "$(/opt/homebrew/bin/brew shellenv)"
}
_dots_load_brew
