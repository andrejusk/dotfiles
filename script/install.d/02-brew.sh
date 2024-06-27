#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install homebrew.
#

if [[ "$OSTYPE" == "darwin"* ]]; then
    export NONINTERACTIVE=1
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        echo "Homebrew is already installed."
    fi

    brew update
    brew --version

    unset NONINTERACTIVE
else
    echo "Skipping: Not macOS"
fi
