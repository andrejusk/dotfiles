#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install dockutil.
#

# macOS only
[[ "$DOTS_OS" != "macos" ]] && { log_skip "Not macOS"; return 0; }

if ! echo "$BREW_FORMULAE" | grep -q "^dockutil$"; then
    brew install dockutil
else
    echo "dockutil is already installed."
fi
log_pass "dockutil installed"
