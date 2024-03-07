#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install iTerm2.
#

if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! brew list --cask iterm2 &>/dev/null; then
        brew install --cask iterm2
    fi
fi
