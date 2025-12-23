#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install iTerm2.
#

# macOS only
[[ "$DOTS_OS" != "macos" ]] && { log_warn "Skipping: Not macOS"; return 0; }

if ! brew list --cask iterm2 &>/dev/null; then
    brew install --cask iterm2
fi
log_pass "iTerm2 installed successfully!"
