# Environment
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export WORKSPACE="${WORKSPACE:-$HOME/Workspace}"
export DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

# Tool roots
export NVM_DIR="${NVM_DIR:-$HOME/.config/nvm}"
export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
export POETRY_ROOT="${POETRY_ROOT:-$HOME/.poetry}"
export HOMEBREW_NO_ANALYTICS=1

# PATH setup with caching
_dots_path_cache="${XDG_CACHE_HOME:-$HOME/.cache}/dots/path"
if [[ -f "$_dots_path_cache" && "$_dots_path_cache" -nt ~/.profile ]]; then
    export PATH="$(cat "$_dots_path_cache")"
else
    [[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && export PATH="$HOME/.local/bin:$PATH"
    [[ ":$PATH:" != *":$PYENV_ROOT/shims:"* ]] && export PATH="$PYENV_ROOT/shims:$PATH"
    [[ ":$PATH:" != *":$PYENV_ROOT/bin:"* ]] && export PATH="$PYENV_ROOT/bin:$PATH"
    [[ ":$PATH:" != *":$POETRY_ROOT/bin:"* ]] && export PATH="$POETRY_ROOT/bin:$PATH"
    [[ -x "/opt/homebrew/bin/brew" && ":$PATH:" != *":/opt/homebrew/bin:"* ]] && export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
    [ -f "$NVM_DIR/alias/lts/jod" ] && export PATH="$NVM_DIR/versions/node/$(cat "$NVM_DIR/alias/lts/jod")/bin:$PATH"
    
    # Cache the result
    mkdir -p "$(dirname "$_dots_path_cache")"
    echo "$PATH" > "$_dots_path_cache"
fi
unset _dots_path_cache
