#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install Colour Contrast Analyser (CCA).
#

# macOS only
[[ "$DOTS_OS" != "macos" ]] && { log_skip "Not macOS"; return 0; }

if ! echo "$BREW_CASKS" | grep -q "^colour-contrast-analyser$"; then
    brew install --cask colour-contrast-analyser
else
    log_skip "CCA already installed"
fi
log_pass "CCA installed"
