#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Display system information with fastfetch.
#

# Skip in Codespaces (cosmetic only)
[[ "$DOTS_ENV" == "codespaces" ]] && { log_skip "Codespaces"; return 0; }

fastfetch --pipe false \
    --logo-color-1 "38;2;44;180;148" \
    --color-title "38;2;44;180;148" \
    --color-keys "38;2;114;144;184" \
    --color-separator "38;2;128;128;128"

