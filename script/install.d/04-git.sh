#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Configure git.
#

if ! command -v git &> /dev/null; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get install -qq git
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install git
    fi
fi

git --version
