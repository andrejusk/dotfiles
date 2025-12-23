#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Configure git.
#

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

git --version
