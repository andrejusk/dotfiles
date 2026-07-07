#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install BetterDisplay.
#

# macOS only
[[ "$DOTS_OS" != "macos" ]] && { log_skip "Not macOS"; return 0; }

if ! echo "$BREW_CASKS" | grep -q "^betterdisplay$"; then
    # --adopt takes over an existing manual /Applications/BetterDisplay.app instead of erroring.
    brew install --cask --adopt betterdisplay
fi
log_pass "BetterDisplay installed"
echo "$BREW_CASK_VERSIONS" | grep "^betterdisplay " | log_quote || true
