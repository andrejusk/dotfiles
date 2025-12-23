#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install BetterDisplay.
#

# macOS only
[[ "$DOTS_OS" != "macos" ]] && { log_warn "Skipping: Not macOS"; return 0; }

if ! brew list --cask betterdisplay &> /dev/null; then
    brew install --cask betterdisplay
else
    echo "BetterDisplay is already installed."
fi
