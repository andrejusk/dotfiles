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
            sudo apt-get install -qq cmatrix &>/dev/null
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install cmatrix
        fi
    fi
    log_pass "cmatrix installed successfully!"
else
    log_warn "Skipping cmatrix configuration"
fi
