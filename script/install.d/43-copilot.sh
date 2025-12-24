#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install GitHub Copilot CLI (globally via npm).
#

if ! command -v npm &>/dev/null; then
    log_warn "npm not found, skipping"
    return 0
fi

# Install if not present
if ! command -v copilot &>/dev/null; then
    log_info "Installing GitHub Copilot CLI..."
    npm install -g @github/copilot --silent
fi

# Verify installation
log_info "GitHub Copilot CLI: $(copilot --version 2>&1 | head -1)"
