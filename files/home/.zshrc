# Prefix all functions with "_dots" for easier profiling
# -----------------------------------------------------------------------------
if [[ -n "$ZSH_BENCH" ]]; then
    zmodload zsh/zprof
fi

# Cache directory
_dots_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/dots"

# Load profile
# -----------------------------------------------------------------------------
_dots_load_profile() {
    source "$HOME/.profile"
}
_dots_load_profile

# Create directories (interactive only)
# -----------------------------------------------------------------------------
_dots_setup_dirs() {
    mkdir -p "$XDG_DATA_HOME" "$XDG_CONFIG_HOME" "$HOME/.local/bin" "$WORKSPACE" "$NVM_DIR" "$_dots_cache_dir"
}
_dots_setup_dirs

# Cache ls colour support detection
# -----------------------------------------------------------------------------
_dots_cache_ls_colours() {
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
_dots_cache_ls_colours

# Load aliases
# -----------------------------------------------------------------------------
[[ -f ~/.aliases ]] && source ~/.aliases

# Load oh-my-zsh
# -----------------------------------------------------------------------------
_dots_load_omz() {
    export DISABLE_AUTO_UPDATE="true"
    export DISABLE_LS_COLORS="true"  # We handle ls colors above
    export ZSH="$HOME/.oh-my-zsh"
    export ZSH_THEME=""  # Disable theme, we build our own prompt
    plugins=(
        z
        zsh-autosuggestions
        zsh-syntax-highlighting
    )
    
    # Cache compinit daily
    autoload -Uz compinit
    if [[ -f ~/.zcompdump && $(date +'%j') == $(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null) ]]; then
        compinit -C
    else
        compinit
    fi
    
    source "$ZSH/oh-my-zsh.sh"
}
_dots_load_omz

# Build shell prompt
# -----------------------------------------------------------------------------

# Constants (configurable)
(( ${+PROMPT_MIN_DURATION} )) || typeset -gi PROMPT_MIN_DURATION=2
(( ${+PROMPT_FLASH_DELAY} )) || typeset -gi PROMPT_FLASH_DELAY=5

# State
typeset -gi _prompt_cmd_start=0
typeset -g  _prompt_base=""
typeset -g  _prompt_flash=""

# Colours (set once)
typeset -gA _pc
_dots_init_colours() {
    if [[ "$COLORTERM" == (truecolor|24bit) ]]; then
        _pc=(
            teal      $'%{\e[38;2;44;180;148m%}'
            orange    $'%{\e[38;2;248;140;20m%}'
            red       $'%{\e[38;2;244;4;4m%}'
            grey      $'%{\e[38;2;114;144;184m%}'
            flash_bg  $'\e[48;2;248;140;20m'
            flash_fg  $'\e[38;2;0;0;0m'
        )
    elif [[ "$TERM" == *256color* ]]; then
        _pc=(
            teal      $'%{\e[38;5;43m%}'
            orange    $'%{\e[38;5;208m%}'
            red       $'%{\e[38;5;196m%}'
            grey      $'%{\e[38;5;103m%}'
            flash_bg  $'\e[48;5;208m'
            flash_fg  $'\e[38;5;0m'
        )
    else
        _pc=(
            teal      $'%{\e[36m%}'
            orange    $'%{\e[33m%}'
            red       $'%{\e[31m%}'
            grey      $'%{\e[34m%}'
            flash_bg  $'\e[43m'
            flash_fg  $'\e[30m'
        )
    fi
    _pc[reset]=$'%{\e[0m%}'
    _pc[bold]=$'%{\e[1m%}'
}

# Abbreviate path: first char for ancestors, keep last 3 full
_dots_abbrev_path() {
    local dir="${PWD/#$HOME/~}"
    local -a parts=( "${(@s:/:)dir}" )
    local count=${#parts[@]}
    
    (( count <= 3 )) && { print -r -- "$dir"; return }
    
    local result=""
    local i
    for (( i=1; i <= count-3; i++ )); do
        result+="${parts[i][1]}/"
    done
    print -r -- "${result}${parts[-3]}/${parts[-2]}/${parts[-1]}"
}

# Session identifier (SSH/container/codespace, empty for local)
_dots_session() {
    [[ -n "$CODESPACE_NAME" ]] && { print -r -- "$CODESPACE_NAME"; return }
    [[ -n "$SSH_CONNECTION" || -n "$SSH_CLIENT" || -n "$SSH_TTY" ]] && { print -r -- "%n@%m"; return }
    [[ -f /.dockerenv ]] && { print -r -- "${DEVCONTAINER_ID:-$(</etc/hostname)}"; return }
}

# Build and cache prompt strings (called on chpwd + init)
_dots_build_cache() {
    local path="$(_dots_abbrev_path)"
    local session="$(_dots_session)"
    local symbol=">" flash_sym=">" reset=$'\e[0m'
    (( EUID == 0 )) && symbol="${_pc[orange]}${_pc[bold]}#${_pc[reset]}" flash_sym="#"
    
    local line1="${_pc[teal]}${path}${_pc[reset]}"
    [[ -n "$session" ]] && line1+="  ${_pc[orange]}${session}${_pc[reset]}"
    
    _prompt_base=$'\n'"${line1}"$'\n'"${symbol} "
    _prompt_flash=$'\n'"${line1}"$'\n'"%{${_pc[flash_bg]}${_pc[flash_fg]}%}${flash_sym}%{${reset}%} "
}

# Hooks
_dots_preexec() { _prompt_cmd_start=$EPOCHSECONDS }

_dots_precmd() {
    local e=$? d=0
    RPROMPT=""
    
    (( e )) && RPROMPT="${_pc[red]}[${e}]${_pc[reset]}"
    
    if (( _prompt_cmd_start )); then
        d=$(( EPOCHSECONDS - _prompt_cmd_start ))
        _prompt_cmd_start=0
        if (( d >= PROMPT_MIN_DURATION )); then
            [[ -n "$RPROMPT" ]] && RPROMPT+=" "
            (( d >= 60 )) && RPROMPT+="${_pc[grey]}($(( d/60 ))m $(( d%60 ))s)${_pc[reset]}" \
                         || RPROMPT+="${_pc[grey]}(${d}s)${_pc[reset]}"
        fi
    fi
    
    PROMPT="$_prompt_base"
}

# CTRL+C widget
_dots_ctrl_c() {
    BUFFER=""
    (( ${+functions[_zsh_autosuggest_clear]} )) && _zsh_autosuggest_clear
    PROMPT="$_prompt_flash" RPROMPT=""
    zle reset-prompt
    zselect -t "$PROMPT_FLASH_DELAY" 2>/dev/null || :
    PROMPT="$_prompt_base"
    zle reset-prompt
}
zle -N _dots_ctrl_c

TRAPINT() {
    [[ -n "$ZLE_STATE" ]] && { zle _dots_ctrl_c; return 0 }
    return 130
}

# Init
_dots_prompt_init() {
    zmodload zsh/datetime zsh/zselect 2>/dev/null
    _dots_init_colours
    _dots_build_cache
    
    setopt PROMPT_SUBST EXTENDED_HISTORY INC_APPEND_HISTORY_TIME
    autoload -Uz add-zsh-hook
    add-zsh-hook preexec _dots_preexec
    add-zsh-hook precmd _dots_precmd
    add-zsh-hook chpwd _dots_build_cache
    
    PROMPT="$_prompt_base" RPROMPT=""
}
_dots_prompt_init

# Lazy Loading
# -----------------------------------------------------------------------------

# NVM lazy loading
_dots_init_nvm() {
    unfunction nvm node npm npx yarn pnpm corepack 2>/dev/null
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
    [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
}

_dots_load_nvm_lazy() {
    local -a nvm_cmds=(nvm node npm npx yarn pnpm corepack)
    for cmd in "${nvm_cmds[@]}"; do
        eval "${cmd}() { _dots_init_nvm; ${cmd} \"\$@\" }"
    done
}

# Pyenv lazy loading
_dots_init_pyenv() {
    unfunction pyenv python python3 pip pip3 poetry pipx 2>/dev/null
    if command -v pyenv &>/dev/null; then
        eval "$(pyenv init -)"
        eval "$(pyenv virtualenv-init -)" 2>/dev/null
    fi
}

_dots_load_pyenv_lazy() {
    local -a pyenv_cmds=(pyenv python python3 pip pip3 poetry pipx)
    for cmd in "${pyenv_cmds[@]}"; do
        eval "${cmd}() { _dots_init_pyenv; ${cmd} \"\$@\" }"
    done
}

# Lazy completions
_dots_setup_lazy_completions() {
    compdef '_dots_init_nvm; _npm' npm 2>/dev/null
    compdef '_dots_init_nvm; _node' node 2>/dev/null
    compdef '_dots_init_pyenv; _pip' pip 2>/dev/null
    compdef '_dots_init_pyenv; _python' python 2>/dev/null
}

# Initialize lazy loading
_dots_lazy_init() {
    _dots_load_nvm_lazy
    _dots_load_pyenv_lazy
    _dots_setup_lazy_completions
}
_dots_lazy_init

# Finish bench profiling
# -----------------------------------------------------------------------------
if [[ -n "$ZSH_BENCH" ]]; then
    zprof
fi
