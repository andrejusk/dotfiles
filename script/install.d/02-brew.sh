#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install homebrew.
#

if [[ "$OSTYPE" == "darwin"* ]]; then
    export NONINTERACTIVE=1
    if ! command -v brew &> /dev/null; then
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    brew update
    brew --version

    unset NONINTERACTIVE
fi
