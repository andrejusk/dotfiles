# Environment
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export WORKSPACE="${WORKSPACE:-$HOME/Workspace}"
if [[ -n "${CODESPACES:-}" ]]; then
    export DOTFILES="${DOTFILES:-/workspaces/.codespaces/.persistedshare/dotfiles}"
else
    export DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
fi
export EDITOR=vim
export VISUAL=vim
export PAGER=less
export BAT_THEME=dots

# Homebrew
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1

# PATH setup with caching (invalidates when base PATH or .profile changes)
_dots_path_cache="${XDG_CACHE_HOME:-$HOME/.cache}/dots/path"
_dots_path_hit=false
if [[ -f "$_dots_path_cache" && "$_dots_path_cache" -nt ~/.profile ]]; then
    { IFS= read -r _k; IFS= read -r _v; } < "$_dots_path_cache"
    [[ "$_k" == "$PATH" ]] && { export PATH="$_v"; _dots_path_hit=true; }
    unset _k _v
fi
if [[ "$_dots_path_hit" != true ]]; then
    _dots_base_path="$PATH"
    [[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && export PATH="$HOME/.local/bin:$PATH"
    [[ -x "/opt/homebrew/bin/brew" && ":$PATH:" != *":/opt/homebrew/bin:"* ]] && export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
    mkdir -p "$(dirname "$_dots_path_cache")"
    printf '%s\n%s\n' "$_dots_base_path" "$PATH" > "$_dots_path_cache"
    unset _dots_base_path
fi
unset _dots_path_cache _dots_path_hit
