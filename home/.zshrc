# Profiling: ZSH_BENCH=1 zsh
[[ -n "$ZSH_BENCH" ]] && zmodload zsh/zprof

# Upgrade xterm-color to xterm-256color (gh cs ssh sets the weaker value)
[[ "$TERM" == "xterm-color" ]] && export TERM=xterm-256color

# Assume truecolor support if terminal advertises 256color (covers SSH, tmux)
[[ -z "$COLORTERM" && "$TERM" == *256color* ]] && export COLORTERM=truecolor

_dots_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/dots"

_dots_load_profile() { source "$HOME/.profile" }
_dots_load_profile

_dots_setup_dirs() {
    mkdir -p "$XDG_DATA_HOME" "$XDG_CONFIG_HOME" "$HOME/.local/bin" "$WORKSPACE" "$_dots_cache_dir"
}
_dots_setup_dirs

_dots_cache_ls_colors() {
    local cache_file="$_dots_cache_dir/ls-colours"
    if [[ -f "$cache_file" ]]; then
        source "$cache_file"
    else
        if command -v gls &>/dev/null; then
            echo 'alias ls="gls --color=auto"' > "$cache_file"
        elif ls --color -d . &>/dev/null 2>&1; then
            echo 'alias ls="ls --color=auto"' > "$cache_file"
        elif ls -G -d . &>/dev/null 2>&1; then
            echo 'alias ls="ls -G"' > "$cache_file"
        fi
        [[ -f "$cache_file" ]] && source "$cache_file"
    fi
    export LS_COLORS='di=38;2;44;180;148:ln=38;2;136;64;156:ex=38;2;248;140;20:fi=0:no=0:*.md=38;2;114;144;184:*.json=38;2;114;144;184:*.yml=38;2;114;144;184:*.yaml=38;2;114;144;184:*.toml=38;2;114;144;184'
}
_dots_cache_ls_colors

[[ -f ~/.aliases ]] && source ~/.aliases

_dots_init_completion() {
    local comp_dir="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/completions"
    [[ -d "$comp_dir" ]] && fpath=("$comp_dir" $fpath)

    autoload -Uz compinit
    # Daily cache invalidation
    local dump="$HOME/.zcompdump"
    if [[ -f "$dump" ]]; then
        zmodload -F zsh/stat b:zstat 2>/dev/null
        local -a dump_stat
        zstat -A dump_stat +mtime "$dump" 2>/dev/null
        if (( dump_stat[1] > EPOCHSECONDS - 86400 )); then
            compinit -C
        else
            compinit
        fi
    else
        compinit
    fi

    # Completion styling
    zstyle ':completion:*' menu select
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
    zstyle ':completion:*' group-name ''
    zstyle ':completion:*:descriptions' format $'\e[38;2;114;144;184m-- %d --\e[0m'
    zstyle ':completion:*:warnings' format $'\e[38;2;244;4;4m-- no matches --\e[0m'
    zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
}
_dots_init_completion

_dots_load_plugins() {
    local plugin_dir="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
    local f="$plugin_dir/zsh-autosuggestions/zsh-autosuggestions.zsh"
    [[ -f "$f" ]] && source "$f"

    # Autosuggestion ghost text colour
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#3c3c3c'

    # syntax-highlighting must be sourced last
    f="$plugin_dir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    [[ -f "$f" ]] && source "$f"

    # Syntax highlighting theme
    typeset -gA ZSH_HIGHLIGHT_STYLES
    ZSH_HIGHLIGHT_STYLES[command]='fg=#2cb494'
    ZSH_HIGHLIGHT_STYLES[builtin]='fg=#2cb494'
    ZSH_HIGHLIGHT_STYLES[alias]='fg=#2cb494'
    ZSH_HIGHLIGHT_STYLES[function]='fg=#2cb494'
    ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#f40404'
    ZSH_HIGHLIGHT_STYLES[path]='underline'
    ZSH_HIGHLIGHT_STYLES[globbing]='fg=#f88c14'
    ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#728cb8'
    ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#728cb8'
    ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#728cb8'
    ZSH_HIGHLIGHT_STYLES[comment]='fg=#808080'
    ZSH_HIGHLIGHT_STYLES[arg0]='fg=#2cb494'
    ZSH_HIGHLIGHT_STYLES[default]='fg=#CCE0D0'
    ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#808080'
    ZSH_HIGHLIGHT_STYLES[redirection]='fg=#f88c14'
    ZSH_HIGHLIGHT_STYLES[option]='fg=#7290b8'
}
_dots_load_plugins

_dots_load_history() {
    HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history"
    HISTSIZE=50000
    SAVEHIST=50000
    [[ -d "${HISTFILE:h}" ]] || mkdir -p "${HISTFILE:h}"
    setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY
}
_dots_load_history

setopt IGNORE_EOF

source "$HOME/.zsh/widgets.zsh"

_dots_load_fzf() {
    command -v fzf &>/dev/null || return
    export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_DEFAULT_OPTS='--style=minimal --layout=reverse --height=40% --border=none --no-scrollbar --prompt="> " --info=inline-right --no-separator --margin=1,0,0,0 --color=fg:#808080,fg+:#CCE0D0,bg:-1,bg+:#1a1a1a --color=hl:#2cb494,hl+:#2cb494,info:#808080,marker:#2cb494 --color=prompt:#2cb494,spinner:#88409C,pointer:#2cb494,header:#808080 --color=border:#3c3c3c,preview-border:#3c3c3c,gutter:#1a1a1a,preview-fg:#CCE0D0'
    # fzf --zsh requires v0.48+
    if fzf --zsh &>/dev/null; then
        source <(fzf --zsh)
    else
        local -a fzf_paths=(
            "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/fzf/shell"
            "/usr/share/fzf"
            "${XDG_DATA_HOME:-$HOME/.local/share}/fzf/shell"
        )
        for dir in "${fzf_paths[@]}"; do
            [[ -f "$dir/key-bindings.zsh" ]] && source "$dir/key-bindings.zsh" && break
        done
        for dir in "${fzf_paths[@]}"; do
            [[ -f "$dir/completion.zsh" ]] && source "$dir/completion.zsh" && break
        done
    fi
}


_dots_load_zoxide() {
    command -v zoxide &>/dev/null || return
    export _ZO_FZF_OPTS="$FZF_DEFAULT_OPTS"
    export _ZO_ECHO=0
    eval "$(zoxide init zsh)"
}

source "$HOME/.zsh/prompt.zsh"

_dots_load_mise() {
    command -v mise &>/dev/null && eval "$(mise activate zsh)"
}
_dots_load_mise
_dots_load_fzf
_dots_load_zoxide

[[ -n "$ZSH_BENCH" ]] && zprof || true
