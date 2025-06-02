#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install Arc Browser.
#

if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! brew list arc &> /dev/null; then
        brew install --cask arc
    else
        echo "Arc Browser is already installed."
    fi
else
    echo -e "${YELLOW}Skipping: Not macOS${NC}"
fi
