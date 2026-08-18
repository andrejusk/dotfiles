#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install the GitHub Copilot desktop app.
#

# macOS only
[[ "$DOTS_OS" != "macos" ]] && { log_skip "Not macOS"; return 0; }

if ! echo "$BREW_CASKS" | grep -q "^github-copilot-app$"; then
    # --adopt takes over an existing manual /Applications install instead of erroring.
    brew install --cask --adopt github-copilot-app
fi
log_pass "GitHub Copilot app installed"
echo "$BREW_CASK_VERSIONS" | grep "^github-copilot-app " | log_quote || true
