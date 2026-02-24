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

# Man pages via bat for syntax highlighting
export MANPAGER="sh -c 'col -bx | sed -e \"s/\x1b\[[0-9;]*m//g\" | bat -l man -p'"

# Less colours for bold/underline (man pages fallback)
export LESS="-R --mouse"
export LESS_TERMCAP_mb=$'\e[1;38;2;248;140;20m'
export LESS_TERMCAP_md=$'\e[1;38;2;64;104;212m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_so=$'\e[38;2;26;26;26;48;2;44;180;148m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_us=$'\e[4;38;2;44;180;148m'
export LESS_TERMCAP_ue=$'\e[0m'

# Use bat as a colourised pager for less
export LESSOPEN="| bat --color=always --style=plain %s 2>/dev/null"

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
