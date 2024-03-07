#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install terraform.
#

if ! command -v "terraform" &>/dev/null; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get install -qq terraform
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew tap hashicorp/tap
        brew install hashicorp/tap/terraform
    fi
fi
