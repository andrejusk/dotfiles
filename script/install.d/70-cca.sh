#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install Colour Contrast Analyser (CCA).
#

if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! command -v cca &> /dev/null; then
        brew install --cask colour-contrast-analyser
    fi
fi
