#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Print system information.
#

# Skip in Codespaces (cosmetic only)
[[ "$DOTS_ENV" == "codespaces" ]] && { log_pass "Skipping in Codespaces"; return 0; }

neofetch
