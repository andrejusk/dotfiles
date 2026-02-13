#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Display system information with fastfetch.
#

# Skip in Codespaces (cosmetic only)
[[ "$DOTS_ENV" == "codespaces" ]] && { log_skip "Codespaces"; return 0; }

fastfetch --pipe false

