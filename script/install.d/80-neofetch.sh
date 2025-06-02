#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install neofetch.
#

if ! command -v neofetch &>/dev/null; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get install -qq neofetch &>/dev/null
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install neofetch
    fi
fi

echo "$(neofetch --version)"
