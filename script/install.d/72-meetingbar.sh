#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install MeetingBar.
#

if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! brew list --cask meetingbar &> /dev/null; then
        brew install --cask meetingbar
    else
        echo "MeetingBar is already installed."
    fi
fi
