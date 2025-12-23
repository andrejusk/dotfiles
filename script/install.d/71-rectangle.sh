#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install Rectangle.
#

# macOS only
[[ "$DOTS_OS" != "macos" ]] && { log_warn "Skipping: Not macOS"; return 0; }

if ! brew list --cask rectangle &> /dev/null; then
    brew install --cask rectangle
else
    echo "Rectangle is already installed."
fi
