#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install Python via mise and configure poetry.
#

# Skip in Codespaces (use pre-installed versions)
[[ "$DOTS_ENV" == "codespaces" ]] && { log_pass "Skipping in Codespaces"; return 0; }

log_info "Installing Python..."
mise install python@3
mise use -g python@3

log_info "Installing Poetry..."
mise install poetry@latest
mise use -g poetry@latest

# Setup Poetry ZSH completions
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [[ -d "$ZSH_CUSTOM/plugins" ]]; then
    POETRY_PLUGIN="$ZSH_CUSTOM/plugins/poetry"
    if [ ! -d "$POETRY_PLUGIN" ]; then
        mkdir -p "$POETRY_PLUGIN"
        poetry completions zsh > "$POETRY_PLUGIN/_poetry"
    fi
fi

# Verify installations
python --version
poetry --version
