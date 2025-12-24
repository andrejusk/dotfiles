#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install MeetingBar.
#

# macOS only
[[ "$DOTS_OS" != "macos" ]] && { log_warn "Skipping: Not macOS"; return 0; }

if ! echo "$BREW_CASKS" | grep -q "^meetingbar$"; then
    brew install --cask meetingbar
else
    echo "MeetingBar is already installed."
fi
