#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install neofetch.
#

if ! command -v neofetch &>/dev/null; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get >/dev/null 2>&1; then
            sudo apt-get install -qq neofetch &>/dev/null
        elif command -v pacman >/dev/null 2>&1; then
            sudo pacman -S --noconfirm neofetch &>/dev/null
        else
            log_warn "Skipping neofetch install: no supported package manager found"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install neofetch
    fi
fi

echo "$(neofetch --version)"
