# Prompt
(( ${+PROMPT_MIN_DURATION} ))  || typeset -gi PROMPT_MIN_DURATION=2    # show duration after N seconds
(( ${+PROMPT_FLASH_DELAY} ))   || typeset -gi PROMPT_FLASH_DELAY=4     # flash prompt for N centiseconds

typeset -gi _dots_prompt_cmd_start=0
typeset -gi _dots_prompt_cmd_ran=0
typeset -gi _dots_prompt_flashing=0
typeset -g  _dots_prompt_symbol="λ"
typeset -g  _dots_prompt_base=""
typeset -gA _dots_pc

_dots_init_colors() {
    if [[ "$COLORTERM" == (truecolor|24bit) ]]; then
        _dots_pc=(
            teal      $'%{\e[38;2;44;180;148m%}'
            teal_bg   $'%{\e[48;2;44;180;148m%}'
            orange    $'%{\e[38;2;248;140;20m%}'
            red       $'%{\e[38;2;244;4;4m%}'
            grey      $'%{\e[38;2;114;144;184m%}'
            grey_bg   $'%{\e[48;2;114;144;184m%}'
            purple    $'%{\e[38;2;136;64;156m%}'
            purple_bg $'%{\e[48;2;136;64;156m%}'
            bright    $'%{\e[38;2;204;224;208m%}'
            dark      $'%{\e[38;2;26;26;26m%}'
            dark_bg   $'%{\e[48;2;26;26;26m%}'
        )
    elif [[ "$TERM" == *256color* ]]; then
        _dots_pc=(
            teal      $'%{\e[38;5;43m%}'
            teal_bg   $'%{\e[48;5;43m%}'
            orange    $'%{\e[38;5;208m%}'
            red       $'%{\e[38;5;196m%}'
            grey      $'%{\e[38;5;103m%}'
            grey_bg   $'%{\e[48;5;103m%}'
            purple    $'%{\e[38;5;133m%}'
            purple_bg $'%{\e[48;5;133m%}'
            bright    $'%{\e[38;5;188m%}'
            dark      $'%{\e[38;5;234m%}'
            dark_bg   $'%{\e[48;5;234m%}'
        )
    else
        _dots_pc=(
            teal      $'%{\e[36m%}'
            teal_bg   $'%{\e[46m%}'
            orange    $'%{\e[33m%}'
            red       $'%{\e[31m%}'
            grey      $'%{\e[34m%}'
            grey_bg   $'%{\e[44m%}'
            purple    $'%{\e[35m%}'
            purple_bg $'%{\e[45m%}'
            bright    $'%{\e[37m%}'
            dark      $'%{\e[30m%}'
            dark_bg   $'%{\e[40m%}'
        )
    fi
    _dots_pc[reset]=$'%{\e[0m%}'
    _dots_pc[bold]=$'%{\e[1m%}'
}

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

_dots_session() {
    local name=""
    if [[ -n "$CODESPACE_NAME" ]]; then
        # Strip final random suffix (e.g. "redesigned-couscous-jp5676rpq5h5wrj" -> "redesigned-couscous")
        name="${CODESPACE_NAME%-*}"
    elif [[ -n "$SSH_CONNECTION" || -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
        name="%n@%m"
    elif [[ -f /.dockerenv ]]; then
        name="${DEVCONTAINER_ID:-$(</etc/hostname)}"
    fi
    [[ -n "$name" ]] && print -r -- "$name"
}

_dots_git_info_sync() {
    # Use git status --short with awk for better performance
    # Avoids shell loops and uses compiled awk for parsing
    local output
    output=$(git status --short --branch --ignore-submodules=dirty 2>/dev/null) || return
    
    local branch="" ahead=0 behind=0 staged=0 unstaged=0 untracked=0
    local detached=0
    
    # Parse efficiently: branch info from first line, counts from rest
    local first_line="${output%%$'\n'*}"
    
    # Extract branch from "## branch...remote [ahead N, behind M]"
    if [[ "$first_line" == "## "* ]]; then
        branch="${first_line#\#\# }"
        # Handle detached HEAD
        if [[ "$branch" == "HEAD (no branch)" ]]; then
            branch=$(git rev-parse --short HEAD 2>/dev/null)
            detached=1
        elif [[ "$branch" == [0-9a-f]##* ]]; then
            branch="${branch:0:7}"
            detached=1
        else
            # Remove tracking info
            branch="${branch%%...*}"
            branch="${branch%% *}"
        fi
        
        # Extract ahead/behind
        [[ "$first_line" =~ "ahead ([0-9]+)" ]] && ahead="${match[1]}"
        [[ "$first_line" =~ "behind ([0-9]+)" ]] && behind="${match[1]}"
    fi
    
    [[ -z "$branch" ]] && return
    
    # Count file status with awk (fast, no shell loops)
    local -a counts
    counts=( $(awk '
        NR == 1 { next }  # Skip branch line
        /^\?\?/ { untracked++; next }
        {
            x = substr($0, 1, 1)
            y = substr($0, 2, 1)
            if (x != " " && x != "?") staged++
            if (y != " " && y != "?") unstaged++
        }
        END { print staged+0, unstaged+0, untracked+0 }
    ' <<< "$output") )
    
    staged=${counts[1]:-0}
    unstaged=${counts[2]:-0}
    untracked=${counts[3]:-0}
    
    # Branch pill: grey for main/master, inverted teal for feature, amber for detached
    local branch_pill
    if (( detached )); then
        branch_pill="${_dots_pc[dark_bg]}${_dots_pc[dark]}(${_dots_pc[orange]}${branch}${_dots_pc[reset]}${_dots_pc[dark_bg]}${_dots_pc[dark]})${_dots_pc[reset]}"
    elif [[ "$branch" == (main|master) ]]; then
        branch_pill="${_dots_pc[dark_bg]}${_dots_pc[dark]}(${_dots_pc[grey]}${branch}${_dots_pc[reset]}${_dots_pc[dark_bg]}${_dots_pc[dark]})${_dots_pc[reset]}"
    else
        branch_pill="${_dots_pc[dark_bg]}${_dots_pc[dark]}(${_dots_pc[purple]}${branch}${_dots_pc[reset]}${_dots_pc[dark_bg]}${_dots_pc[dark]})${_dots_pc[reset]}"
    fi
    local info="$branch_pill"
    
    local dirty=""
    local sep=""
    if (( staged )); then
        dirty+="${_dots_pc[teal]}+${staged}"
        sep=" "
    fi
    if (( unstaged )); then
        dirty+="${sep}${_dots_pc[grey]}~${unstaged}"
        sep=" "
    fi
    if (( untracked )); then
        dirty+="${sep}${_dots_pc[orange]}?${untracked}"
    fi
    
    local arrows=""
    sep=""
    if (( ahead )); then
        arrows+="${_dots_pc[teal]}↑${ahead}"
        sep=" "
    fi
    if (( behind )); then
        arrows+="${sep}${_dots_pc[orange]}↓${behind}"
    fi
    
    if [[ -n "$dirty" || -n "$arrows" ]]; then
        local stats=""
        [[ -n "$dirty" ]] && stats+="$dirty"
        [[ -n "$dirty" && -n "$arrows" ]] && stats+=" "
        [[ -n "$arrows" ]] && stats+="$arrows"
        info+=" ${stats}"
    fi
    
    print -r -- "$info"
}

# Async git info
typeset -g _dots_git_info_result=""
typeset -g _dots_git_info_pwd=""
typeset -g _dots_git_async_fd=""

_dots_git_async_callback() {
    local fd=$1
    local result=""
    # Use sysread for efficient non-blocking read from fd
    if [[ -n "$fd" ]] && sysread -i "$fd" result 2>/dev/null; then
        result="${result%$'\n'}"  # trim trailing newline
        _dots_git_info_result="$result"
        _dots_build_dots_prompt_base
        PROMPT="$_dots_prompt_base"
        # Only reset prompt if not in a special ZLE widget (e.g. fzf)
        if zle && [[ "${WIDGET:-}" != _dots_* ]]; then
            zle reset-prompt 2>/dev/null
        fi
    fi
    # Clean up
    exec {fd}<&-
    zle -F "$fd" 2>/dev/null
    _dots_git_async_fd=""
}

_dots_git_async_start() {
    # Check if we're in a git repo
    local git_dir
    git_dir=$(git rev-parse --git-dir 2>/dev/null) || return
    
    # Cancel any pending async job (reuse single worker)
    if [[ -n "$_dots_git_async_fd" ]]; then
        exec {_dots_git_async_fd}<&- 2>/dev/null
        zle -F "$_dots_git_async_fd" 2>/dev/null
        _dots_git_async_fd=""
    fi
    
    # Start background job
    exec {_dots_git_async_fd}< <(
        _dots_git_info_sync
    )
    zle -F "$_dots_git_async_fd" _dots_git_async_callback
}

_dots_build_dots_prompt_base() {
    local dir_path="$(_dots_abbrev_path)"
    local symbol="${_dots_pc[grey]}${_dots_prompt_symbol}${_dots_pc[reset]}"
    (( EUID == 0 )) && symbol="${_dots_pc[orange]}${_dots_pc[bold]}#${_dots_pc[reset]}"
    
    local line1="${_dots_pc[dark_bg]}${_dots_pc[dark]}#${_dots_pc[teal]}${dir_path}${_dots_pc[reset]}${_dots_pc[dark_bg]}${_dots_pc[dark]}#${_dots_pc[reset]}"
    [[ -n "$_dots_git_info_result" ]] && line1+=" ${_dots_git_info_result}"
    
    _dots_prompt_base=$'\n'"${line1}"$'\n'"${symbol} "
}

_dots_preexec() {
    _dots_prompt_cmd_start=$EPOCHSECONDS
    _dots_prompt_cmd_ran=1
}

_dots_precmd() {
    local e=$? d=0
    # Only show exit code if a command actually ran
    (( _dots_prompt_cmd_ran )) || e=0
    _dots_prompt_cmd_ran=0
    # First prompt should never show error from shell init
    [[ -z "$_dots_first_prompt" ]] && { _dots_first_prompt=1; e=0; }
    
    # Build RPROMPT: time, error, host
    local rp_parts=()
    
    if (( _dots_prompt_cmd_start )); then
        d=$(( EPOCHSECONDS - _dots_prompt_cmd_start ))
        _dots_prompt_cmd_start=0
        if (( d >= PROMPT_MIN_DURATION )); then
            (( d >= 60 )) && rp_parts+=("${_dots_pc[grey]}($(( d/60 ))m$(( d%60 ))s)${_dots_pc[reset]}") \
                         || rp_parts+=("${_dots_pc[grey]}(${d}s)${_dots_pc[reset]}")
        fi
    fi
    
    (( e )) && rp_parts+=("${_dots_pc[red]}[${e}]${_dots_pc[reset]}")
    
    local session="$(_dots_session)"
    [[ -n "$session" ]] && rp_parts+=("${_dots_pc[dark_bg]}${_dots_pc[dark]}[${_dots_pc[orange]}${session}${_dots_pc[reset]}${_dots_pc[dark_bg]}${_dots_pc[dark]}]${_dots_pc[reset]}")
    
    RPROMPT="${(j: :)rp_parts}"
    
    # On directory change, clear git info until async refreshes
    if [[ "$PWD" != "$_dots_git_info_pwd" ]]; then
        _dots_git_info_pwd="$PWD"
        _dots_git_info_result=""
    fi
    
    _dots_build_dots_prompt_base
    _dots_git_async_start
    PROMPT="$_dots_prompt_base"
}



TRAPINT() {
    # Only customize when ZLE is active (at prompt, not during command)
    if [[ -o zle ]] && [[ -o interactive ]] && (( ${+WIDGET} )); then
        if [[ -z "$BUFFER" ]] && (( ! _dots_prompt_flashing )); then
            # Empty buffer: flash the prompt symbol
            _dots_prompt_flashing=1
            local git_part=""
            [[ -n "$_dots_git_info_result" ]] && git_part=" ${_dots_git_info_result}"
            local flash_prompt=$'\n'"${_dots_pc[dark_bg]}${_dots_pc[dark]}#${_dots_pc[teal]}$(_dots_abbrev_path)${_dots_pc[reset]}${_dots_pc[dark_bg]}${_dots_pc[dark]}#${_dots_pc[reset]}${git_part}"$'\n'$'%{\e[48;2;248;140;20m\e[30m%}'"${_dots_prompt_symbol}"$' %{\e[0m%}'
            PROMPT="$flash_prompt"
            zle reset-prompt
            zselect -t $PROMPT_FLASH_DELAY
            _dots_prompt_flashing=0
            PROMPT="$_dots_prompt_base"
            zle reset-prompt
            return 0
        elif [[ -n "$BUFFER" ]]; then
            # Buffer has content: clear autosuggest, then default behavior
            zle autosuggest-clear 2>/dev/null
        fi
    fi
    # Propagate signal: use special return code -1 to let zsh handle normally
    return $((128 + ${1:-2}))
}

_dots_prompt_init() {
    zmodload zsh/datetime 2>/dev/null
    zmodload zsh/zselect 2>/dev/null
    zmodload zsh/system 2>/dev/null
    _dots_init_colors
    _dots_build_dots_prompt_base
    
    setopt PROMPT_SUBST EXTENDED_HISTORY INC_APPEND_HISTORY_TIME
    autoload -Uz add-zsh-hook
    add-zsh-hook preexec _dots_preexec
    add-zsh-hook precmd _dots_precmd
    add-zsh-hook chpwd _dots_build_dots_prompt_base
    
    PROMPT="$_dots_prompt_base" RPROMPT=""
}
_dots_prompt_init
