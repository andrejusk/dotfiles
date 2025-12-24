#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install Node.js via mise.
#

# Skip in Codespaces (use pre-installed versions)
[[ "$DOTS_ENV" == "codespaces" ]] && { log_pass "Skipping in Codespaces"; return 0; }

log_info "Installing Node.js..."
mise install node@lts
mise use -g node@lts

# Verify installations
echo "node $(node --version)"
echo "npm $(npm --version)"
