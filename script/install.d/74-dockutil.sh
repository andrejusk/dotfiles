#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install dockutil.
#

# macOS only
[[ "$DOTS_OS" != "macos" ]] && { log_warn "Skipping: Not macOS"; return 0; }

if ! brew list dockutil &> /dev/null; then
    brew install dockutil
else
    echo "dockutil is already installed."
fi
