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
_dots_build_prompt() {
    local final_prompt=""

    local dir_section="%{$fg_bold[blue]%}%~"
    final_prompt+="$dir_section "

    local prompt_char="\λ"
    local prompt_suffix="%{$reset_color%}%${prompt_char}%{$reset_color%}"
    final_prompt+="$prompt_suffix "

    PROMPT="$final_prompt"
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
