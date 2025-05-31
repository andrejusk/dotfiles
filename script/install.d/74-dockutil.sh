#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install dockutil.
#

if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! brew list dockutil &> /dev/null; then
        brew install dockutil
    else
        echo "dockutil is already installed."
    fi
else
    echo "Skipping: Not macOS"
fi
