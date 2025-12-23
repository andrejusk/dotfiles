#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install MeetingBar.
#

# macOS only
[[ "$DOTS_OS" != "macos" ]] && { log_warn "Skipping: Not macOS"; return 0; }

if ! brew list --cask meetingbar &> /dev/null; then
    brew install --cask meetingbar
else
    echo "MeetingBar is already installed."
fi
