#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install Visual Studio Code.
#

# macOS only
[[ "$DOTS_OS" != "macos" ]] && { log_skip "Not macOS"; return 0; }

if ! echo "$BREW_CASKS" | grep -q "^visual-studio-code$"; then
    brew install --cask visual-studio-code
else
    log_skip "VSCode already installed"
fi
log_pass "VSCode installed"
