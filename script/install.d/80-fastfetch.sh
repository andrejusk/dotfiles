#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install fastfetch (fast system information tool).
#

# Skip in Codespaces (cosmetic tool)
[[ "$DOTS_ENV" == "codespaces" ]] && { log_pass "Skipping in Codespaces"; return 0; }

if ! command -v fastfetch &>/dev/null; then
    case "$DOTS_PKG" in
        apt)
            sudo apt-get install -qq fastfetch &>/dev/null
            ;;
        pacman)
            yay -S --noconfirm fastfetch &>/dev/null
            ;;
        brew)
            brew install fastfetch
            ;;
        *)
            log_warn "Skipping fastfetch install: no supported package manager found"
            ;;
    esac
fi

echo "fastfetch: $(fastfetch --version 2>&1 | head -1)"
