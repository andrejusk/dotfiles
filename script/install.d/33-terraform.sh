#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install Terraform via mise.
#

# Skip in Codespaces (not needed)
[[ "$DOTS_ENV" == "codespaces" ]] && { log_pass "Skipping in Codespaces"; return 0; }

log_info "Installing Terraform..."
mise install terraform@latest
mise use -g terraform@latest

# Verify installation
terraform --version
