#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install bat and build theme cache from dotfiles.
#

if ! command -v bat &> /dev/null; then
    case "$DOTS_PKG" in
        brew)
            brew install bat
            ;;
        apt)
            sudo apt-get install -qq bat
            ;;
        pacman)
            sudo pacman -S --noconfirm bat
            ;;
        *)
            log_warn "Skipping bat install: no supported package manager found"
            return 0
            ;;
    esac
fi

bat --version | log_quote

bat cache --build --quiet
log_pass "bat theme cache built"
