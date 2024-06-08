#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install cmatrix.
#

if ! command -v "cmatrix" &>/dev/null; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get install -qq cmatrix &>/dev/null
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install cmatrix
    fi
fi
