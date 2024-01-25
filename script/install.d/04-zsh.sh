#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Configure zsh shell.
#

if ! bin_in_path zsh; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        install zsh
    fi
fi

zsh --version
