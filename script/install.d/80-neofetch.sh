#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install neofetch.
#

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
