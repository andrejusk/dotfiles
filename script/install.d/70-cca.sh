#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install Colour Contrast Analyser (CCA).
#

# macOS only
[[ "$DOTS_OS" != "macos" ]] && { log_warn "Skipping: Not macOS"; return 0; }

if ! brew list --cask colour-contrast-analyser &> /dev/null; then
    brew install --cask colour-contrast-analyser
else
    echo "Colour Contrast Analyser (CCA) is already installed."
fi
