# Helper function for warnings
# -----------------------------------------------------------------
_dots_warn() {
    echo "WARNING: $*" >&2
}

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
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        \. "$NVM_DIR/nvm.sh" --no-use || _dots_warn "Failed to load nvm.sh"
    else
        _dots_warn "nvm.sh not found at $NVM_DIR/nvm.sh"
    fi
    if [ -s "$NVM_DIR/bash_completion" ]; then
        \. "$NVM_DIR/bash_completion" || _dots_warn "Failed to load nvm bash_completion"
    fi
}
_dots_load_nvm

node_alias="$NVM_DIR/alias/lts/jod"
if [ -f "$node_alias" ]; then
    VERSION=$(cat "$node_alias")
    node_bin_path="$NVM_DIR/versions/node/$VERSION/bin"
    if [[ ":$PATH:" != *":$node_bin_path:"* ]]; then
        export PATH="$node_bin_path:$PATH"
    fi
    
    # Check Node.js version if node is available
    if command -v node >/dev/null 2>&1; then
        current_node_version=$(node --version 2>/dev/null)
        # VERSION from alias file may or may not have 'v' prefix
        expected_version="$VERSION"
        case "$expected_version" in
            v*) ;;
            *) expected_version="v$expected_version" ;;
        esac
        if [ -n "$current_node_version" ] && [ -n "$expected_version" ] && [ "$current_node_version" != "$expected_version" ]; then
            _dots_warn "Node.js version mismatch: current=$current_node_version, expected=$expected_version"
        fi
        unset current_node_version expected_version
    fi
else
    # Only warn about missing node if nvm was successfully loaded
    if command -v nvm >/dev/null 2>&1 && ! command -v node >/dev/null 2>&1; then
        _dots_warn "Node.js not configured: alias file not found at $node_alias"
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
    if command -v pyenv >/dev/null 2>&1; then
        eval "$(pyenv init --path)" || _dots_warn "Failed to initialize pyenv"
    else
        _dots_warn "pyenv not found in PATH"
    fi
}
_dots_load_pyenv

# Check Python version if pyenv is available
expected_python_version="3.13.7"
if command -v pyenv >/dev/null 2>&1; then
    if command -v python >/dev/null 2>&1; then
        current_python_version=$(python --version 2>&1 | awk '{print $2}')
        if [ -n "$current_python_version" ] && [ "$current_python_version" != "$expected_python_version" ]; then
            _dots_warn "Python version mismatch: current=$current_python_version, expected=$expected_python_version"
        fi
        unset current_python_version
    elif command -v python3 >/dev/null 2>&1; then
        current_python_version=$(python3 --version 2>&1 | awk '{print $2}')
        if [ -n "$current_python_version" ] && [ "$current_python_version" != "$expected_python_version" ]; then
            _dots_warn "Python version mismatch: current=$current_python_version, expected=$expected_python_version"
        fi
        unset current_python_version
    fi
fi
unset expected_python_version

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
    if [ -x "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)" || _dots_warn "Failed to initialize homebrew"
    fi
}
_dots_load_brew
