#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Configure git.
#

if ! command -v git &> /dev/null; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get >/dev/null 2>&1; then
            sudo apt-get install -qq git
        elif command -v pacman >/dev/null 2>&1; then
            sudo pacman -S --noconfirm git
        else
            log_warn "Skipping git install: no supported package manager found"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install git
    fi
fi

git --version
