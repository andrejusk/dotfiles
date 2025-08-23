#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install cmatrix.
#

# skip if in CODESPACES
if [[ -n "$CODESPACES" ]]; then
    log_warn "Running in GitHub Codespaces"
    export SKIP_CMATRIX_CONFIG=1
fi

if [[ -z "$SKIP_CMATRIX_CONFIG" ]]; then
    if ! command -v cmatrix &> /dev/null; then
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            if command -v apt-get >/dev/null 2>&1; then
                sudo apt-get install -qq cmatrix &>/dev/null
            elif command -v pacman >/dev/null 2>&1; then
                sudo pacman -S --noconfirm cmatrix &>/dev/null
            else
                log_warn "Skipping cmatrix install: no supported package manager found"
            fi
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install cmatrix
        fi
    fi
    log_pass "cmatrix installed successfully!"
else
    log_warn "Skipping cmatrix configuration"
fi
