#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install Colour Contrast Analyser (CCA).
#

if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! brew list --cask colour-contrast-analyser &> /dev/null; then
        brew install --cask colour-contrast-analyser
    else
        echo "Colour Contrast Analyser (CCA) is already installed."
    fi
else
    echo -e "${YELLOW}Skipping: Not macOS${NC}"
fi
