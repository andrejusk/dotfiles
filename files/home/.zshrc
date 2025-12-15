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

# 1. Constants & Configuration (only set once)
(( ${+PROMPT_MIN_DURATION} )) || typeset -gi PROMPT_MIN_DURATION=2       # Minimum seconds to show execution time
(( ${+PROMPT_FLASH_DELAY} )) || typeset -gi PROMPT_FLASH_DELAY=5         # Flash duration in centiseconds (50ms)
(( ${+EXIT_SIGINT} )) || typeset -gi EXIT_SIGINT=130                     # Exit code for SIGINT (128 + 2)

# State variables
typeset -gi _prompt_cmd_start_time=0
typeset -gi _prompt_cmd_duration=0
typeset -g _prompt_cached_session=""
typeset -g _prompt_cached_path=""
typeset -g _prompt_symbol=""
typeset -g _prompt_flash_symbol=""

# 2. Colour Setup (run once)
_dots_setup_colours() {
    if [[ "$COLORTERM" == "truecolor" || "$COLORTERM" == "24bit" ]]; then
        # True colour
        _pc_teal=$'%{\e[38;2;44;180;148m%}'
        _pc_orange=$'%{\e[38;2;248;140;20m%}'
        _pc_red=$'%{\e[38;2;244;4;4m%}'
        _pc_bluegrey=$'%{\e[38;2;114;144;184m%}'
        _pc_flash_bg=$'\e[48;2;248;140;20m'
        _pc_flash_fg=$'\e[38;2;0;0;0m'
    elif [[ "${TERM}" == *256color* ]] || \
         { (( ${+terminfo[colors]} )) && (( ${terminfo[colors]} >= 256 )); }; then
        # 256 colour
        _pc_teal=$'%{\e[38;5;43m%}'
        _pc_orange=$'%{\e[38;5;208m%}'
        _pc_red=$'%{\e[38;5;196m%}'
        _pc_bluegrey=$'%{\e[38;5;103m%}'
        _pc_flash_bg=$'\e[48;5;208m'
        _pc_flash_fg=$'\e[38;5;0m'
    else
        # Basic colour
        _pc_teal=$'%{\e[36m%}'
        _pc_orange=$'%{\e[33m%}'
        _pc_red=$'%{\e[31m%}'
        _pc_bluegrey=$'%{\e[34m%}'
        _pc_flash_bg=$'\e[43m'
        _pc_flash_fg=$'\e[30m'
    fi
    _pc_reset=$'%{\e[0m%}'
    _pc_bold=$'%{\e[1m%}'
}

# 3. Cached State Functions
# Update cached path (called on chpwd and precmd)
_dots_update_path() {
    local dir="${PWD/#$HOME/~}"
    local -a parts
    local prefix=""
    local separator=""
    
    # Handle leading / or ~
    if [[ "$dir" == /* ]]; then
        prefix="/"
        dir="${dir:1}"
    elif [[ "$dir" == "~/"* ]]; then
        prefix="~"
        separator="/"
        dir="${dir:2}"
    elif [[ "$dir" == "~" ]]; then
        _prompt_cached_path="~"
        return
    fi
    
    if [[ -z "$dir" ]]; then
        _prompt_cached_path="$prefix"
        return
    fi
    
    parts=("${(@s:/:)dir}")
    local count=${#parts[@]}
    
    if (( count <= 3 )); then
        _prompt_cached_path="${prefix}${separator}${dir}"
    else
        local result=""
        local i
        for (( i=1; i <= count-3; i++ )); do
            result+="${parts[$i]:0:1}/"
        done
        result+="${parts[-3]}/${parts[-2]}/${parts[-1]}"
        _prompt_cached_path="${prefix}${separator}${result}"
    fi
}

# Initialize session identifier (called once at startup)
_dots_init_session() {
    # GitHub Codespace
    if [[ -n "$CODESPACE_NAME" ]]; then
        _prompt_cached_session="$CODESPACE_NAME"
        return
    fi
    # Dev container
    if [[ -n "$REMOTE_CONTAINERS_IPC" || -f /.dockerenv ]]; then
        if [[ -n "$DEVCONTAINER_ID" ]]; then
            _prompt_cached_session="$DEVCONTAINER_ID"
            return
        fi
        # Try container hostname
        if [[ -f /etc/hostname ]]; then
            _prompt_cached_session="$(</etc/hostname)"
            return
        fi
    fi
    # SSH session
    if [[ -n "$SSH_CONNECTION" || -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
        _prompt_cached_session="%n@%m"
        return
    fi
    # Local - no identifier
    _prompt_cached_session=""
}

# Initialize symbols (called once at startup)
_dots_init_symbols() {
    local reset=$'\e[0m'
    if [[ $EUID -eq 0 ]]; then
        _prompt_symbol="${_pc_orange}${_pc_bold}#${_pc_reset}"
        _prompt_flash_symbol="%{${_pc_flash_bg}${_pc_flash_fg}%}#%{${reset}%}"
    else
        _prompt_symbol=">"
        _prompt_flash_symbol="%{${_pc_flash_bg}${_pc_flash_fg}%}>%{${reset}%}"
    fi
}

# 4. Hooks
# Pre-exec hook: record command start time
_dots_preexec() {
    _prompt_cmd_start_time=$EPOCHSECONDS
}

# Pre-cmd hook: calculate duration, set prompt
_dots_precmd() {
    local last_exit=$?
    
    # Calculate duration if we have a start time
    if (( _prompt_cmd_start_time > 0 )); then
        _prompt_cmd_duration=$(( EPOCHSECONDS - _prompt_cmd_start_time ))
        _prompt_cmd_start_time=0
    else
        _prompt_cmd_duration=0
    fi
    
    # Update cached path
    _dots_update_path
    
    # Build prompt components
    local line1="${_pc_teal}${_prompt_cached_path}${_pc_reset}"
    [[ -n "$_prompt_cached_session" ]] && line1+="  ${_pc_orange}${_prompt_cached_session}${_pc_reset}"
    
    local line2_right=""
    # Exit code (if non-zero)
    if (( last_exit != 0 )); then
        line2_right="${_pc_red}[${last_exit}]${_pc_reset}"
    fi
    
    # Execution time (if >= minimum duration) - inline formatting
    if (( _prompt_cmd_duration >= PROMPT_MIN_DURATION )); then
        [[ -n "$line2_right" ]] && line2_right+=" "
        if (( _prompt_cmd_duration >= 60 )); then
            line2_right+="${_pc_bluegrey}($(( _prompt_cmd_duration / 60 ))m $(( _prompt_cmd_duration % 60 ))s)${_pc_reset}"
        else
            line2_right+="${_pc_bluegrey}(${_prompt_cmd_duration}s)${_pc_reset}"
        fi
    fi
    
    # Set prompts
    PROMPT=$'\n'"${line1}"$'\n'"${_prompt_symbol} "
    RPROMPT="${line2_right}"
}

# 5. Widgets
# CTRL+C ZLE widget (can modify BUFFER)
_dots_ctrl_c_widget() {
    BUFFER=""
    # Clear autosuggestion if plugin is active
    if (( ${+functions[_zsh_autosuggest_clear]} )); then
        _zsh_autosuggest_clear
    fi
    
    # Build line1 using cached values
    local line1="${_pc_teal}${_prompt_cached_path}${_pc_reset}"
    [[ -n "$_prompt_cached_session" ]] && line1+="  ${_pc_orange}${_prompt_cached_session}${_pc_reset}"
    
    # Flash prompt
    PROMPT=$'\n'"${line1}"$'\n'"${_prompt_flash_symbol} "
    RPROMPT=""
    zle reset-prompt
    
    # Non-blocking delay using zselect (with fallback)
    zselect -t "$PROMPT_FLASH_DELAY" 2>/dev/null || :
    
    # Restore normal prompt
    PROMPT=$'\n'"${line1}"$'\n'"${_prompt_symbol} "
    zle reset-prompt
}
zle -N _dots_ctrl_c_widget

# CTRL+C handler via TRAPINT (signal-level, not ZLE)
TRAPINT() {
    # Check if we're in ZLE (line editor active)
    if [[ -n "$ZLE_STATE" ]]; then
        # Call widget to handle buffer clearing
        zle _dots_ctrl_c_widget
        return 0
    fi
    # Not in ZLE, use default behaviour
    return $(( EXIT_SIGINT ))
}

# 6. Initialisation
_dots_build_prompt() {
    # Load required modules
    zmodload zsh/datetime 2>/dev/null
    zmodload zsh/zselect 2>/dev/null
    
    # Setup colours and symbols
    _dots_setup_colours
    _dots_init_symbols
    _dots_init_session
    
    # Enable prompt substitution
    setopt PROMPT_SUBST
    
    # Extended history format
    setopt EXTENDED_HISTORY
    setopt INC_APPEND_HISTORY_TIME
    
    # Register hooks
    autoload -Uz add-zsh-hook
    add-zsh-hook preexec _dots_preexec
    add-zsh-hook precmd _dots_precmd
    add-zsh-hook chpwd _dots_update_path
    
    # Initial prompt (will be set by precmd)
    PROMPT="> "
    RPROMPT=""
}

_dots_build_prompt

# Finish bench profiling
# -----------------------------------------------------------------------------
if [[ -n "$ZSH_BENCH" ]]; then
    zprof
fi

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
