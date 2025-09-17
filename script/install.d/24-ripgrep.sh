#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install ripgrep.
#

if ! command -v rg &>/dev/null; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update -qq &&
            sudo apt-get install -qq ripgrep
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install ripgrep
    fi
fi

rg --version