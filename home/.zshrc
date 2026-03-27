# Profiling: ZSH_BENCH=1 zsh
[[ -n "$ZSH_BENCH" ]] && zmodload zsh/zprof

# Terminal capabilities
[[ "$TERM" == "xterm-color" ]] && export TERM=xterm-256color
[[ -z "$COLORTERM" && "$TERM" == *256color* ]] && export COLORTERM=truecolor

_dots_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/dots"

# Cache eval output keyed on binary mtime — busts on brew upgrade / tool update
_dots_cached_eval() {
    local name="$1" bin="$2"; shift 2
    local cache="$_dots_cache_dir/${name}.zsh"
    if [[ -f "$cache" && "$cache" -nt "$bin" ]]; then
        source "$cache"
    else
        "$@" > "$cache" 2>/dev/null
        if [[ -s "$cache" ]]; then
            zcompile "$cache" 2>/dev/null
            source "$cache"
        else
            rm -f "$cache"; return 1
        fi
    fi
}

# --- Environment ---

_dots_load_profile() { source "$HOME/.profile" }
_dots_load_profile

_dots_setup_dirs() {
    local d; for d in "$XDG_DATA_HOME" "$XDG_CONFIG_HOME" "$HOME/.local/bin" "$WORKSPACE" "$_dots_cache_dir"; do
        [[ -d "$d" ]] || mkdir -p "$d"
    done
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

# --- Completion (lazy — deferred until first Tab press) ---

_dots_init_completion() {
    local comp_dir="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/completions"
    [[ -d "$comp_dir" ]] && fpath=("$comp_dir" $fpath)

    autoload -Uz compinit
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

    zstyle ':completion:*' menu select
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
    zstyle ':completion:*' group-name ''
    zstyle ':completion:*:descriptions' format $'\e[38;2;114;144;184m-- %d --\e[0m'
    zstyle ':completion:*:warnings' format $'\e[38;2;248;140;20m-- no matches --\e[0m'
    zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
}

# Stub that loads real completion on first Tab, then replays the keypress
_dots_lazy_comp_widget() {
    _dots_init_completion
    # Point fzf fallback to real completion before removing this widget
    fzf_default_completion=expand-or-complete
    zle -D _dots_lazy_comp_widget
    if (( ${+widgets[fzf-completion]} )); then
        bindkey '^I' fzf-completion
        zle fzf-completion "$@"
    else
        bindkey '^I' expand-or-complete
        zle expand-or-complete "$@"
    fi
}
zle -N _dots_lazy_comp_widget
bindkey '^I' _dots_lazy_comp_widget

# --- History & options ---

_dots_load_history() {
    HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history"
    HISTSIZE=50000
    SAVEHIST=50000
    [[ -d "${HISTFILE:h}" ]] || mkdir -p "${HISTFILE:h}"
    setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY
}
_dots_load_history

stty -ixon 2>/dev/null

# --- Tool init (cached) ---

_dots_load_mise() {
    local bin="${commands[mise]:-}"
    [[ -n "$bin" ]] || return
    _dots_cached_eval mise "$bin" mise activate --shims zsh
}

# fzf env vars (needed by widgets and zoxide before fzf init loads)
if [[ -n "${commands[fzf]:-}" ]]; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_DEFAULT_OPTS='--style=minimal --layout=reverse --height=40% --border=none --no-scrollbar --prompt="> " --info=inline-right --no-separator --margin=1,0,0,0 --color=fg:#808080,fg+:#CCE0D0,bg:-1,bg+:#1A1A1A --color=hl:#2CB494,hl+:#2CB494,info:#808080,marker:#2CB494 --color=prompt:#2CB494,spinner:#88409C,pointer:#2CB494,header:#808080 --color=border:#3C3C3C,preview-border:#3C3C3C,gutter:#1A1A1A,preview-fg:#CCE0D0'
fi

_dots_load_fzf() {
    local bin="${commands[fzf]:-}"
    [[ -n "$bin" ]] || return
    if ! _dots_cached_eval fzf "$bin" fzf --zsh; then
        local -a fzf_paths=(
            "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/fzf/shell"
            "/usr/share/fzf"
            "${XDG_DATA_HOME:-$HOME/.local/share}/fzf/shell"
        )
        local dir
        for dir in "${fzf_paths[@]}"; do
            [[ -f "$dir/key-bindings.zsh" ]] && source "$dir/key-bindings.zsh" && break
        done
        for dir in "${fzf_paths[@]}"; do
            [[ -f "$dir/completion.zsh" ]] && source "$dir/completion.zsh" && break
        done
    fi
}

_dots_load_zoxide() {
    local bin="${commands[zoxide]:-}"
    [[ -n "$bin" ]] || return
    export _ZO_FZF_OPTS="$FZF_DEFAULT_OPTS"
    export _ZO_ECHO=0
    _dots_cached_eval zoxide "$bin" zoxide init zsh
}

_dots_load_mise
_dots_load_zoxide

# --- Interactive shell ---

source "$HOME/.zsh/prompt.zsh"

# Load fzf + widgets after first prompt renders (zle-line-init fires before first keystroke)
autoload -Uz add-zle-hook-widget
_dots_lazy_widgets() {
    _dots_load_fzf
    source "$HOME/.zsh/widgets.zsh"
    add-zle-hook-widget -d zle-line-init _dots_lazy_widgets
}
add-zle-hook-widget zle-line-init _dots_lazy_widgets

[[ -n "$ZSH_BENCH" ]] && zprof || true
