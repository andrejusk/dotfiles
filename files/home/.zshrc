# Profiling: ZSH_BENCH=1 zsh
[[ -n "$ZSH_BENCH" ]] && zmodload zsh/zprof

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
        if ls --color -d . &>/dev/null; then
            echo 'alias ls="ls --color=auto"' > "$cache_file"
        elif ls -G -d . &>/dev/null; then
            echo 'alias ls="ls -G"' > "$cache_file"
        fi
        [[ -f "$cache_file" ]] && source "$cache_file"
    fi
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
}
_dots_init_completion

_dots_load_plugins() {
    local plugin_dir="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
    local f="$plugin_dir/zsh-autosuggestions/zsh-autosuggestions.zsh"
    [[ -f "$f" ]] && source "$f"
    # syntax-highlighting must be sourced last
    f="$plugin_dir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    [[ -f "$f" ]] && source "$f"
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
    export FZF_DEFAULT_OPTS='--layout=reverse --height=40% --prompt="> " --info=inline-right --no-separator'
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
