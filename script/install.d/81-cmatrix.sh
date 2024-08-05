#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install cmatrix.
#

# Check if running in a GitHub Codespace
if [ -n "$CODESPACES" ]; then
    echo "Skipping cmatrix installation: Running in a GitHub Codespace"
else
    if ! command -v "cmatrix" &>/dev/null; then
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt-get install -qq cmatrix &>/dev/null
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install cmatrix
        fi
    fi
fi
