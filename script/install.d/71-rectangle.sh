#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install Rectangle.
#

if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! brew list --cask rectangle &> /dev/null; then
        brew install --cask rectangle
    else
        echo "Rectangle is already installed."
    fi
else
    log_warn "Skipping: Not macOS"
fi
