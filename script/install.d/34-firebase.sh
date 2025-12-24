#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install Firebase CLI via mise.
#

# Skip in Codespaces (not needed)
[[ "$DOTS_ENV" == "codespaces" ]] && { log_pass "Skipping in Codespaces"; return 0; }

log_info "Installing Firebase CLI..."
mise install firebase@latest
mise use -g firebase@latest

# Verify installation
echo "firebase: $(firebase --version)"
