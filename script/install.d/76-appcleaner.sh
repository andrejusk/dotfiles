#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install AppCleaner.
#

if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! brew list --cask appcleaner &> /dev/null; then
        brew install --cask appcleaner
        echo "AppCleaner has been installed."
    else
        echo "AppCleaner is already installed."
    fi
else
    log_warn "Skipping: Not macOS"
fi
