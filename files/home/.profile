# Environment
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export WORKSPACE="${WORKSPACE:-$HOME/Workspace}"
export DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

# Homebrew
export HOMEBREW_NO_ANALYTICS=1

# PATH setup with caching
_dots_path_cache="${XDG_CACHE_HOME:-$HOME/.cache}/dots/path"
if [[ -f "$_dots_path_cache" && "$_dots_path_cache" -nt ~/.profile ]]; then
    export PATH="$(cat "$_dots_path_cache")"
else
    [[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && export PATH="$HOME/.local/bin:$PATH"
    [[ -x "/opt/homebrew/bin/brew" && ":$PATH:" != *":/opt/homebrew/bin:"* ]] && export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
    
    # Cache the result
    mkdir -p "$(dirname "$_dots_path_cache")"
    echo "$PATH" > "$_dots_path_cache"
fi
unset _dots_path_cache
