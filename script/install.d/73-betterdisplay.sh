#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install BetterDisplay.
#

if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! brew list --cask betterdisplay &> /dev/null; then
        brew install --cask betterdisplay
    else
        echo "BetterDisplay is already installed."
    fi
else
    echo -e "${YELLOW}Skipping: Not macOS${NC}"
fi
