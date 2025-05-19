# Prefix all functions with "_dots" for easier profiling
# -----------------------------------------------------------------------------
if [[ -n "$ZSH_BENCH" ]]; then
    zmodload zsh/zprof
fi

# Load profile
# -----------------------------------------------------------------------------
_dots_load_profile() {
    source $HOME/.profile
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
    source $ZSH/oh-my-zsh.sh
}
_dots_load_omz

# Load nvm
# -----------------------------------------------------------------------------
_dots_load_nvm() {
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}
_dots_load_nvm

# -----------------------------------------------------------------------------
_dots_load_brew() {
    export HOMEBREW_NO_ANALYTICS=1
    [ -x "/opt/homebrew/bin/brew" ] && eval "$(/opt/homebrew/bin/brew shellenv)"
}
_dots_load_brew

# -----------------------------------------------------------------------------
_dots_load_pyenv() {
    [ -x `command -v pyenv` ] && eval "$(pyenv init --path)"
}
_dots_load_pyenv

# -----------------------------------------------------------------------------
_dots_build_prompt() {
    local final_prompt=""

    local dir_section="%{$fg_bold[blue]%}%~"
    final_prompt+="$dir_section "

    local prompt_char="%{$reset_color%}%%"
    final_prompt+="$prompt_char "

    PROMPT="$final_prompt"
}
_dots_build_prompt

# -----------------------------------------------------------------------------
if [[ -n "$ZSH_BENCH" ]]; then
    zprof
fi
