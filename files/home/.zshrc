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

# Configuration: Commands excluded from execution time display
typeset -ga PROMPT_EXCLUDED_COMMANDS=(
    vim nvim vi nano emacs code
    less more man
    top htop btop watch
    ssh mosh tmux screen
    python python3 node irb ghci
    psql mysql sqlite3
    fzf
)
# Maximum duration (seconds) before time is hidden (likely interactive)
typeset -g PROMPT_MAX_DURATION=3600

# State variables
typeset -g _prompt_first_prompt=1
typeset -g _prompt_cmd_start_time=0
typeset -g _prompt_cmd_duration=0
typeset -g _prompt_last_cmd=""
typeset -g _prompt_buffer_empty=1

# Detect colour support and set palette
_dots_setup_colours() {
    local tc256 tcbasic
    if [[ "$COLORTERM" == "truecolor" || "$COLORTERM" == "24bit" ]]; then
        # True colour
        _pc_teal=$'%{\e[38;2;44;180;148m%}'
        _pc_orange=$'%{\e[38;2;248;140;20m%}'
        _pc_red=$'%{\e[38;2;244;4;4m%}'
        _pc_bluegrey=$'%{\e[38;2;114;144;184m%}'
    elif [[ "${TERM}" == *256color* || "${terminfo[colors]}" -ge 256 ]] 2>/dev/null; then
        # 256 colour
        _pc_teal=$'%{\e[38;5;43m%}'
        _pc_orange=$'%{\e[38;5;208m%}'
        _pc_red=$'%{\e[38;5;196m%}'
        _pc_bluegrey=$'%{\e[38;5;103m%}'
    else
        # Basic colour
        _pc_teal=$'%{\e[36m%}'
        _pc_orange=$'%{\e[33m%}'
        _pc_red=$'%{\e[31m%}'
        _pc_bluegrey=$'%{\e[34m%}'
    fi
    _pc_reset=$'%{\e[0m%}'
    _pc_bold=$'%{\e[1m%}'
}

# Abbreviate path: keep last 2 components full, abbreviate rest to first char
_dots_abbrev_path() {
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
        echo "~"
        return
    fi
    
    [[ -z "$dir" ]] && { echo "$prefix"; return; }
    
    parts=("${(@s:/:)dir}")
    local count=${#parts[@]}
    
    if (( count <= 3 )); then
        echo "${prefix}${separator}${dir}"
    else
        local result=""
        local i
        for (( i=1; i <= count-3; i++ )); do
            result+="${parts[$i]:0:1}/"
        done
        result+="${parts[-3]}/${parts[-2]}/${parts[-1]}"
        echo "${prefix}${separator}${result}"
    fi
}

# Get session identifier
_dots_session_id() {
    # GitHub Codespace
    if [[ -n "$CODESPACE_NAME" ]]; then
        echo "$CODESPACE_NAME"
        return
    fi
    # Dev container
    if [[ -n "$REMOTE_CONTAINERS_IPC" || -f /.dockerenv ]]; then
        if [[ -n "$DEVCONTAINER_ID" ]]; then
            echo "$DEVCONTAINER_ID"
            return
        fi
        # Try container hostname
        if [[ -f /etc/hostname ]]; then
            cat /etc/hostname
            return
        fi
    fi
    # SSH session
    if [[ -n "$SSH_CONNECTION" || -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
        echo "%n@%m"
        return
    fi
    # Local - no identifier
    echo ""
}

# Check if command is in excluded list
_dots_is_excluded_cmd() {
    local cmd="$1"
    local base_cmd="${cmd%% *}"
    base_cmd="${base_cmd##*/}"
    
    local excluded
    for excluded in "${PROMPT_EXCLUDED_COMMANDS[@]}"; do
        [[ "$base_cmd" == "$excluded" ]] && return 0
    done
    return 1
}

# Format duration
_dots_format_duration() {
    local seconds=$1
    if (( seconds >= 60 )); then
        local mins=$(( seconds / 60 ))
        local secs=$(( seconds % 60 ))
        echo "(${mins}m ${secs}s)"
    else
        echo "(${seconds}s)"
    fi
}

# Pre-exec hook: record command start time
_dots_preexec() {
    _prompt_cmd_start_time=$EPOCHSECONDS
    _prompt_last_cmd="$1"
}

# Pre-cmd hook: calculate duration, set prompt
_dots_precmd() {
    local last_exit=$?
    local duration=0
    
    # Suppress exit code 130 (SIGINT/CTRL+C) - not a real error
    if (( last_exit == 130 )); then
        last_exit=0
    fi
    
    # Calculate duration if we have a start time
    if (( _prompt_cmd_start_time > 0 )); then
        duration=$(( EPOCHSECONDS - _prompt_cmd_start_time ))
        _prompt_cmd_duration=$duration
        _prompt_cmd_start_time=0
    else
        _prompt_cmd_duration=0
    fi
    
    # Build prompt components
    local abbrev_dir="$(_dots_abbrev_path)"
    local session="$(_dots_session_id)"
    
    # Line 1: Working directory (left), Session (right)
    local line1_left="${_pc_teal}${abbrev_dir}${_pc_reset}"
    local line1_right=""
    if [[ -n "$session" ]]; then
        line1_right="${_pc_orange}${session}${_pc_reset}"
    fi
    
    # Line 2: Input symbol (left), Exit code + Duration (right)
    local symbol
    if [[ $EUID -eq 0 ]]; then
        symbol="${_pc_orange}${_pc_bold}#${_pc_reset}"
    else
        symbol=">"
    fi
    
    local line2_right=""
    # Exit code (if non-zero)
    if (( last_exit != 0 )); then
        line2_right="${_pc_red}[${last_exit}]${_pc_reset}"
    fi
    
    # Execution time (if >= 2s and not excluded and not over max)
    if (( _prompt_cmd_duration >= 2 )) && \
       (( _prompt_cmd_duration < PROMPT_MAX_DURATION )) && \
       ! _dots_is_excluded_cmd "$_prompt_last_cmd"; then
        local time_str="$(_dots_format_duration $_prompt_cmd_duration)"
        if [[ -n "$line2_right" ]]; then
            line2_right+=" "
        fi
        line2_right+="${_pc_bluegrey}${time_str}${_pc_reset}"
    fi
    
    # Build newline prefix (blank line before prompt)
    local nl_prefix=$'\n'
    
    # Set prompts
    PROMPT="${nl_prefix}${line1_left}"$'\n'"${symbol} "
    
    # RPROMPT needs to handle two-line display
    # We use prompt_subst and newlines in RPROMPT
    if [[ -n "$line1_right" || -n "$line2_right" ]]; then
        # For two-line RPROMPT, we need a workaround
        # Actually RPROMPT only applies to last line, so we use a trick
        # Place session on line 1 via PROMPT, exit/time on line 2 via RPROMPT
        PROMPT="${nl_prefix}${line1_left}$(if [[ -n "$line1_right" ]]; then echo "  ${line1_right}"; fi)"$'\n'"${symbol} "
        RPROMPT="${line2_right}"
    else
        RPROMPT=""
    fi
}

# Handle CTRL+C behaviour
_dots_line_init() {
    _prompt_buffer_empty=1
}

_dots_keymap_select() {
    _prompt_buffer_empty=$(( ${#BUFFER} == 0 ))
}

_dots_self_insert() {
    _prompt_buffer_empty=0
    zle .self-insert
}

_dots_backward_delete_char() {
    zle .backward-delete-char
    _prompt_buffer_empty=$(( ${#BUFFER} == 0 ))
}

# CTRL+C ZLE widget (can modify BUFFER)
_dots_ctrl_c_widget() {
    BUFFER=""
    # Clear autosuggestion if plugin is active
    if (( ${+functions[_zsh_autosuggest_clear]} )); then
        _zsh_autosuggest_clear
    fi
    
    # Build flash symbol (orange background, black foreground)
    local flash_bg flash_fg
    if [[ "$COLORTERM" == "truecolor" || "$COLORTERM" == "24bit" ]]; then
        flash_bg=$'\e[48;2;248;140;20m'
        flash_fg=$'\e[38;2;0;0;0m'
    elif [[ "${TERM}" == *256color* ]] 2>/dev/null; then
        flash_bg=$'\e[48;5;208m'
        flash_fg=$'\e[38;5;0m'
    else
        flash_bg=$'\e[43m'
        flash_fg=$'\e[30m'
    fi
    local reset=$'\e[0m'
    
    local flash_symbol="%{${flash_bg}${flash_fg}%}>%{${reset}%} "
    [[ $EUID -eq 0 ]] && flash_symbol="%{${flash_bg}${flash_fg}%}#%{${reset}%} "
    
    # Build flash prompt (same structure as normal, with blank line)
    local abbrev_dir="$(_dots_abbrev_path)"
    local session="$(_dots_session_id)"
    local line1="${_pc_teal}${abbrev_dir}${_pc_reset}"
    [[ -n "$session" ]] && line1+="  ${_pc_orange}${session}${_pc_reset}"
    
    # Include blank line prefix (same as precmd does for non-first prompts)
    local nl_prefix=$'\n'
    
    PROMPT="${nl_prefix}${line1}"$'\n'"${flash_symbol}"
    RPROMPT=""
    zle reset-prompt
    
    # Brief delay then restore
    sleep 0.1
    
    # Restore normal prompt (with blank line)
    local symbol="> "
    [[ $EUID -eq 0 ]] && symbol="${_pc_orange}${_pc_bold}#${_pc_reset} "
    PROMPT="${nl_prefix}${line1}"$'\n'"${symbol}"
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
    return $(( 128 + 2 ))
}

_dots_build_prompt() {
    # Load required modules
    zmodload zsh/datetime 2>/dev/null
    
    # Setup colours
    _dots_setup_colours
    
    # Enable prompt substitution
    setopt PROMPT_SUBST
    
    # Extended history format
    setopt EXTENDED_HISTORY
    setopt INC_APPEND_HISTORY_TIME
    
    # Register hooks
    autoload -Uz add-zsh-hook
    add-zsh-hook preexec _dots_preexec
    add-zsh-hook precmd _dots_precmd
    
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
