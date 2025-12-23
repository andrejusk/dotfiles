#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install neofetch.
#

# Skip in Codespaces (cosmetic tool)
[[ "$DOTS_ENV" == "codespaces" ]] && { log_pass "Skipping in Codespaces"; return 0; }

if ! command -v neofetch &>/dev/null; then
    case "$DOTS_PKG" in
        apt)
            sudo apt-get install -qq neofetch &>/dev/null
            ;;
        pacman)
            yay -S --noconfirm neofetch &>/dev/null
            ;;
        brew)
            brew install neofetch
            ;;
        *)
            log_warn "Skipping neofetch install: no supported package manager found"
            ;;
    esac
fi

echo "$(neofetch --version)"
