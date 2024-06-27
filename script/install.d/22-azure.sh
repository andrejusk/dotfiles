#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#  Install Azure CLI.
#

if ! command -v az &>/dev/null; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt
        curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install azure-cli
    fi
fi

az --version
