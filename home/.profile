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

# Machine-local overrides (DOTS_THEME, credentials, etc.)
[[ -f ~/.profile.local ]] && source ~/.profile.local

# Theme detection: explicit > COLORFGBG > macOS appearance > dark
_dots_detect_theme() {
    [[ -n "${DOTS_THEME:-}" ]] && return
    if [[ -n "${COLORFGBG:-}" ]]; then
        local bg="${COLORFGBG##*;}"
        if (( bg >= 7 )); then
            export DOTS_THEME=light
        else
            export DOTS_THEME=dark
        fi
        return
    fi
    if [[ "$OSTYPE" == darwin* ]] && defaults read -g AppleInterfaceStyle &>/dev/null; then
        export DOTS_THEME=dark
    else
        export DOTS_THEME=${DOTS_THEME:-dark}
    fi
}
_dots_detect_theme

# Theme-aware tool configuration
if [[ "$DOTS_THEME" == light ]]; then
    export BAT_THEME=dots-light
    export GLAMOUR_STYLE=light
    export DELTA_FEATURES=light
else
    export BAT_THEME=dots
    export GLAMOUR_STYLE=dark
    export DELTA_FEATURES=dark
fi

# Git colour overrides: .gitconfig hex values are tuned for dark backgrounds
# and include near-white shades (header, branch.local) that vanish on light.
# Applied via GIT_CONFIG_COUNT overlay so no per-invocation config rewrite.
_dots_git_light_overrides() {
    set -- \
        color.status.added          '#1A8A72' \
        color.status.changed        '#3A5C94' \
        color.status.untracked      '#B46400 italic' \
        color.status.branch         '#1A8A72' \
        color.status.header         '#3A5A50' \
        color.diff.meta             '#6A2078' \
        color.diff.frag             '#2848A0' \
        color.diff.old              '#B46400' \
        color.diff.new              '#1A8A72' \
        color.diff.context          '#606060' \
        color.diff.commit           '#B46400' \
        color.branch.current        '#1A8A72 bold' \
        color.branch.local          '#3A5A50' \
        color.branch.remote         '#2848A0' \
        color.branch.upstream       '#3A5C94' \
        color.decorate.branch       '#1A8A72' \
        color.decorate.remoteBranch '#2848A0' \
        color.decorate.tag          '#B46400' \
        color.decorate.stash        '#6A2078' \
        color.decorate.HEAD         '#B46400 bold' \
        alias.l  'log --pretty=format:%C(#B46400)%h\ %ad%C(#1A8A72)%d\ %Creset%s%C(#606060)\ [%cn] --decorate --date=short' \
        alias.ls 'log --pretty=format:%C(#B46400)%h%C(#1A8A72)%d\ %Creset%s%C(#606060)\ [%cn] --decorate' \
        alias.ll 'log --pretty=format:%C(#B46400)%h%C(#1A8A72)%d\ %Creset%s%C(#606060)\ [%cn] --decorate --numstat' \
        alias.ld 'log --pretty=format:%C(#B46400)%h\ %ad%C(#1A8A72)%d\ %Creset%s%C(#606060)\ [%cn] --decorate --date=relative'
    local i=0
    export GIT_CONFIG_COUNT=$(( $# / 2 ))
    while [ $# -ge 2 ]; do
        export "GIT_CONFIG_KEY_${i}=$1"
        export "GIT_CONFIG_VALUE_${i}=$2"
        shift 2
        i=$(( i + 1 ))
    done
}
if [[ "$DOTS_THEME" == light ]]; then
    _dots_git_light_overrides
fi

# Man pages via bat for syntax highlighting
export MANPAGER="sh -c 'col -bx | sed -e \"s/\x1b\[[0-9;]*m//g\" | bat -l man -p'"

# Less colours for bold/underline (man pages fallback)
export LESS="-R --mouse"
if [[ "$DOTS_THEME" == light ]]; then
    export LESS_TERMCAP_mb=$'\e[1;38;2;200;100;0m'
    export LESS_TERMCAP_md=$'\e[1;38;2;50;80;170m'
    export LESS_TERMCAP_me=$'\e[0m'
    export LESS_TERMCAP_so=$'\e[38;2;253;246;227;48;2;44;180;148m'
    export LESS_TERMCAP_se=$'\e[0m'
    export LESS_TERMCAP_us=$'\e[4;38;2;44;180;148m'
    export LESS_TERMCAP_ue=$'\e[0m'
else
    export LESS_TERMCAP_mb=$'\e[1;38;2;248;140;20m'
    export LESS_TERMCAP_md=$'\e[1;38;2;64;104;212m'
    export LESS_TERMCAP_me=$'\e[0m'
    export LESS_TERMCAP_so=$'\e[38;2;26;26;26;48;2;44;180;148m'
    export LESS_TERMCAP_se=$'\e[0m'
    export LESS_TERMCAP_us=$'\e[4;38;2;44;180;148m'
    export LESS_TERMCAP_ue=$'\e[0m'
fi

# Use bat as a colourised pager for less
export LESSOPEN="| bat --color=always --style=plain %s 2>/dev/null"

# Homebrew — update deliberately (run `brew update` by hand) so installs stay
# deterministic and don't pull rolling-release changes unbidden. The installer
# already sets this for its own run (script/install); this covers interactive use.
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_NO_AUTO_UPDATE=1

# GitHub Copilot CLI
export COPILOT_AUTO_UPDATE=false

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
