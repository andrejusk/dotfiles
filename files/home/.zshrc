# Prefix all functions with "_dots" for easier profiling
# -----------------------------------------------------------------------------
if [[ -n "$ZSH_BENCH" ]]; then
    zmodload zsh/zprof
fi

# Load profile
# -----------------------------------------------------------------------------
_dots_load_profile() {
    source "$HOME/.profile"
}
_dots_load_profile

# Load oh-my-zsh
# -----------------------------------------------------------------------------
_dots_load_omz() {
    export DISABLE_AUTO_UPDATE="true"
    export ZSH="$HOME/.oh-my-zsh"
    plugins=(
        z
        zsh-autosuggestions
        zsh-syntax-highlighting
    )
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

# Finish bench profiling
# -----------------------------------------------------------------------------
if [[ -n "$ZSH_BENCH" ]]; then
    zprof
fi

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
