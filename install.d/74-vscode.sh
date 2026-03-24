#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install Visual Studio Code.
#

# macOS only
[[ "$DOTS_OS" != "macos" ]] && { log_skip "Not macOS"; return 0; }

if ! echo "$BREW_CASKS" | grep -q "^visual-studio-code$"; then
    brew install --cask visual-studio-code
fi
log_pass "VSCode installed"
echo "$BREW_CASK_VERSIONS" | grep "^visual-studio-code " | log_quote
