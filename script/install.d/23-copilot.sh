#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install GitHub Copilot CLI.
#

if ! command -v copilot &>/dev/null; then
    if command -v npm &>/dev/null; then
        npm install -g @github/copilot
    else
        log_warn "Skipping GitHub Copilot CLI install: npm not found"
    fi
fi

copilot --version
