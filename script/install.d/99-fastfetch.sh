#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Display system information with fastfetch.
#

# Skip in Codespaces (cosmetic only)
[[ "$DOTS_ENV" == "codespaces" ]] && { log_pass "Skipping in Codespaces"; return 0; }

fastfetch --pipe false
