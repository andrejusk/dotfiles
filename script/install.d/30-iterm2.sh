#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install iTerm2.
#

if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! brew list --cask iterm2 &>/dev/null; then
        brew install --cask iterm2
    fi
    log_pass "iTerm2 installed successfully!"
else
    log_warn "Skipping: Not macOS"
fi
