#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install cmatrix.
#

# skip if in CODESPACES
if [[ -n "$CODESPACES" ]]; then
    echo -e "${GREY}Running in GitHub Codespaces${NC}"
    export SKIP_CMATRIX_CONFIG=1
fi

if [[ -z "$SKIP_CMATRIX_CONFIG" ]]; then
    if ! command -v cmatrix &> /dev/null; then
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt-get install -qq cmatrix &>/dev/null
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install cmatrix
        fi
    fi
    echo -e "${GREEN}cmatrix installed successfully!${NC}"
else
    echo -e "${YELLOW}Skipping cmatrix configuration${NC}"
fi
