#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install homebrew.
#

if [[ "$OSTYPE" == "darwin"* ]]; then
    export NONINTERACTIVE=1
    if ! bin_in_path brew; then
        download_run https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh /bin/bash
    else
        brew update
    fi

    brew --version

    unset NONINTERACTIVE
fi
