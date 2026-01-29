#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install cmatrix.
#

# skip if in Codespaces
[[ "$DOTS_ENV" == "codespaces" ]] && { log_pass "Skipping in Codespaces"; return 0; }

if ! command -v cmatrix &> /dev/null; then
    case "$DOTS_PKG" in
        apt)
            sudo apt-get install -qq cmatrix &>/dev/null
            ;;
        pacman)
            sudo pacman -S --noconfirm cmatrix &>/dev/null
            ;;
        brew)
            brew install cmatrix
            ;;
        *)
            log_warn "Skipping cmatrix install: no supported package manager found"
            ;;
    esac
fi
log_pass "cmatrix installed successfully!"
