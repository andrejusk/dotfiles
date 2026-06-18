#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install Ghostty.
#

# macOS only
[[ "$DOTS_OS" != "macos" ]] && { log_skip "Not macOS"; return 0; }

if ! echo "$BREW_CASKS" | grep -q "^ghostty$"; then
    brew install --cask ghostty
fi
log_pass "Ghostty installed"
echo "$BREW_CASK_VERSIONS" | grep "^ghostty " | log_quote || true
