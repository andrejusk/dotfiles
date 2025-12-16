# Profiling: ZSH_BENCH=1 zsh
[[ -n "$ZSH_BENCH" ]] && zmodload zsh/zprof

_dots_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/dots"

_dots_load_profile() { source "$HOME/.profile" }
_dots_load_profile

_dots_setup_dirs() {
    mkdir -p "$XDG_DATA_HOME" "$XDG_CONFIG_HOME" "$HOME/.local/bin" "$WORKSPACE" "$NVM_DIR" "$_dots_cache_dir"
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

_dots_load_omz() {
    export DISABLE_AUTO_UPDATE="true"
    export DISABLE_LS_COLORS="true"
    export ZSH="$HOME/.oh-my-zsh"
    export ZSH_THEME=""
    plugins=(
        z
        zsh-autosuggestions
        zsh-syntax-highlighting
    )
    
    # Daily security check: skip compaudit if already checked today
    local marker="$_dots_cache_dir/.compaudit_checked"
    local today=$(date +'%Y-%j')
    if [[ -f "$marker" ]] && [[ "$(cat "$marker" 2>/dev/null)" == "$today" ]]; then
        export ZSH_DISABLE_COMPFIX="true"
    else
        echo "$today" > "$marker"
    fi
    
    source "$ZSH/oh-my-zsh.sh"
}
_dots_load_omz

# Prompt
(( ${+PROMPT_MIN_DURATION} ))  || typeset -gi PROMPT_MIN_DURATION=2    # show duration after N seconds
(( ${+PROMPT_FLASH_DELAY} ))   || typeset -gi PROMPT_FLASH_DELAY=4     # flash prompt for N centiseconds

typeset -gi _prompt_cmd_start=0
typeset -gi _prompt_cmd_ran=0
typeset -gi _prompt_flashing=0
typeset -g  _prompt_base=""
typeset -gA _pc

_dots_init_colors() {
    if [[ "$COLORTERM" == (truecolor|24bit) ]]; then
        _pc=(
            teal      $'%{\e[38;2;44;180;148m%}'
            orange    $'%{\e[38;2;248;140;20m%}'
            red       $'%{\e[38;2;244;4;4m%}'
            grey      $'%{\e[38;2;114;144;184m%}'
        )
    elif [[ "$TERM" == *256color* ]]; then
        _pc=(
            teal      $'%{\e[38;5;43m%}'
            orange    $'%{\e[38;5;208m%}'
            red       $'%{\e[38;5;196m%}'
            grey      $'%{\e[38;5;103m%}'
        )
    else
        _pc=(
            teal      $'%{\e[36m%}'
            orange    $'%{\e[33m%}'
            red       $'%{\e[31m%}'
            grey      $'%{\e[34m%}'
        )
    fi
    _pc[reset]=$'%{\e[0m%}'
    _pc[bold]=$'%{\e[1m%}'
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
    [[ -n "$CODESPACE_NAME" ]] && { print -r -- "$CODESPACE_NAME"; return }
    [[ -n "$SSH_CONNECTION" || -n "$SSH_CLIENT" || -n "$SSH_TTY" ]] && { print -r -- "%n@%m"; return }
    [[ -f /.dockerenv ]] && { print -r -- "${DEVCONTAINER_ID:-$(</etc/hostname)}"; return }
}

_dots_git_info() {
    local git_dir
    git_dir="$(git rev-parse --git-dir 2>/dev/null)" || return
    
    local branch=""
    if [[ -f "$git_dir/HEAD" ]]; then
        local head=$(<"$git_dir/HEAD")
        if [[ "$head" == ref:* ]]; then
            branch="${head#ref: refs/heads/}"
        else
            branch="${head:0:7}"
        fi
    fi
    [[ -z "$branch" ]] && return
    
    local info="${_pc[grey]}${branch}${_pc[reset]}"
    
    # Status: staged, unstaged, untracked
    local staged=0 unstaged=0 untracked=0
    local status_line
    while IFS= read -r status_line; do
        case "${status_line:0:2}" in
            \?\?) (( untracked++ )) ;;
            ?[MDAUR]) (( unstaged++ )) ;;
        esac
        case "${status_line:0:1}" in
            [MDAUR]) (( staged++ )) ;;
        esac
    done < <(git status --porcelain 2>/dev/null)
    
    local dirty=""
    (( staged ))    && dirty+="${_pc[teal]}+${staged}${_pc[reset]}"
    (( unstaged ))  && dirty+="${_pc[orange]}~${unstaged}${_pc[reset]}"
    (( untracked )) && dirty+="${_pc[grey]}?${untracked}${_pc[reset]}"
    [[ -n "$dirty" ]] && info+=" ${dirty}"
    
    # Ahead/behind
    local upstream
    upstream="$(git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)"
    if [[ -n "$upstream" ]]; then
        local ahead=0 behind=0
        local ab
        ab="$(git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)"
        if [[ -n "$ab" ]]; then
            ahead="${ab%%$'\t'*}"
            behind="${ab##*$'\t'}"
            local arrows=""
            (( ahead ))  && arrows+="${_pc[teal]}↑${ahead}${_pc[reset]}"
            (( behind )) && arrows+="${_pc[orange]}↓${behind}${_pc[reset]}"
            [[ -n "$arrows" ]] && info+=" ${arrows}"
        fi
    fi
    
    print -r -- "$info"
}

_dots_build_prompt_base() {
    local dir_path="$(_dots_abbrev_path)"
    local symbol="${_pc[grey]}>${_pc[reset]}"
    (( EUID == 0 )) && symbol="${_pc[orange]}${_pc[bold]}#${_pc[reset]}"
    
    local line1="${_pc[teal]}${dir_path}${_pc[reset]}"
    local git_info="$(_dots_git_info)"
    [[ -n "$git_info" ]] && line1+="  ${git_info}"
    
    _prompt_base=$'\n'"${line1}"$'\n'"${symbol} "
}

_dots_preexec() {
    _prompt_cmd_start=$EPOCHSECONDS
    _prompt_cmd_ran=1
}

_dots_precmd() {
    local e=$? d=0
    # Only show exit code if a command actually ran
    (( _prompt_cmd_ran )) || e=0
    _prompt_cmd_ran=0
    # First prompt should never show error from shell init
    [[ -z "$_dots_first_prompt" ]] && { _dots_first_prompt=1; e=0; }
    
    # Build RPROMPT: time, error, host
    local rp_parts=()
    
    if (( _prompt_cmd_start )); then
        d=$(( EPOCHSECONDS - _prompt_cmd_start ))
        _prompt_cmd_start=0
        if (( d >= PROMPT_MIN_DURATION )); then
            (( d >= 60 )) && rp_parts+=("${_pc[grey]}$(( d/60 ))m $(( d%60 ))s${_pc[reset]}") \
                         || rp_parts+=("${_pc[grey]}${d}s${_pc[reset]}")
        fi
    fi
    
    (( e )) && rp_parts+=("${_pc[red]}${e}${_pc[reset]}")
    
    local session="$(_dots_session)"
    [[ -n "$session" ]] && rp_parts+=("${_pc[orange]}${session}${_pc[reset]}")
    
    RPROMPT="${(j: :)rp_parts}"
    
    _dots_build_prompt_base
    PROMPT="$_prompt_base"
}



TRAPINT() {
    # Only customize when ZLE is active (at prompt, not during command)
    if [[ -o zle ]] && (( ${+WIDGET} )); then
        if [[ -z "$BUFFER" ]] && (( ! _prompt_flashing )); then
            # Empty buffer: flash the prompt symbol
            _prompt_flashing=1
            local git_info="$(_dots_git_info)"
            local git_part=""
            [[ -n "$git_info" ]] && git_part="  ${git_info}"
            local flash_prompt=$'\n'"${_pc[teal]}$(_dots_abbrev_path)${_pc[reset]}${git_part}"$'\n'$'%{\e[48;2;248;140;20m\e[30m%}> %{\e[0m%}'
            PROMPT="$flash_prompt"
            zle reset-prompt
            zselect -t $PROMPT_FLASH_DELAY
            _prompt_flashing=0
            PROMPT="$_prompt_base"
            zle reset-prompt
            return 0
        elif [[ -n "$BUFFER" ]]; then
            # Buffer has content: clear autosuggest, then default behavior
            zle autosuggest-clear 2>/dev/null
        fi
    fi
    return $((128 + 2))
}

_dots_prompt_init() {
    zmodload zsh/datetime 2>/dev/null
    zmodload zsh/zselect 2>/dev/null
    _dots_init_colors
    _dots_build_prompt_base
    
    setopt PROMPT_SUBST EXTENDED_HISTORY INC_APPEND_HISTORY_TIME
    autoload -Uz add-zsh-hook
    add-zsh-hook preexec _dots_preexec
    add-zsh-hook precmd _dots_precmd
    add-zsh-hook chpwd _dots_build_prompt_base
    
    PROMPT="$_prompt_base" RPROMPT=""
}
_dots_prompt_init

# Lazy loading
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

_dots_setup_lazy_completions() {
    compdef '_dots_init_nvm; _npm' npm 2>/dev/null
    compdef '_dots_init_nvm; _node' node 2>/dev/null
    compdef '_dots_init_pyenv; _pip' pip 2>/dev/null
    compdef '_dots_init_pyenv; _python' python 2>/dev/null
}

_dots_lazy_init() {
    _dots_load_nvm_lazy
    _dots_load_pyenv_lazy
    _dots_setup_lazy_completions
}
_dots_lazy_init

[[ -n "$ZSH_BENCH" ]] && zprof
