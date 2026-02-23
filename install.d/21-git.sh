#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Configure git.
#

# Skip in Codespaces (pre-installed in universal image)
[[ "$DOTS_ENV" == "codespaces" ]] && { git --version | log_quote; return 0; }

if ! command -v git &> /dev/null; then
    case "$DOTS_PKG" in
        apt)
            sudo apt-get install -qq git
            ;;
        pacman)
            sudo pacman -S --noconfirm git
            ;;
        brew)
            brew install git
            ;;
        *)
            log_warn "Skipping git install: no supported package manager found"
            return 0
            ;;
    esac
fi

git --version | log_quote
log_pass "git configured"
