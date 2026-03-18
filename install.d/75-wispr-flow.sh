#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install Wispr Flow.
#

# macOS only
[[ "$DOTS_OS" != "macos" ]] && { log_skip "Not macOS"; return 0; }

if ! echo "$BREW_CASKS" | grep -q "^wispr-flow$"; then
    brew install --cask wispr-flow
else
    log_skip "Wispr Flow already installed"
fi
log_pass "Wispr Flow installed"
