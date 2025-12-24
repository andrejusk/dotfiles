#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install iTerm2.
#

# macOS only
[[ "$DOTS_OS" != "macos" ]] && { log_warn "Skipping: Not macOS"; return 0; }

if ! echo "$BREW_CASKS" | grep -q "^iterm2$"; then
    brew install --cask iterm2
fi
log_pass "iTerm2 installed successfully!"
