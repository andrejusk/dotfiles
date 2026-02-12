#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install Rectangle.
#

# macOS only
[[ "$DOTS_OS" != "macos" ]] && { log_skip "Not macOS"; return 0; }

if ! echo "$BREW_CASKS" | grep -q "^rectangle$"; then
    brew install --cask rectangle
else
    echo "Rectangle is already installed."
fi
log_pass "Rectangle installed"
