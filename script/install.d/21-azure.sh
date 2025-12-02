#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#  Install Azure CLI.
#

if ! command -v az &>/dev/null; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get >/dev/null 2>&1; then
            # https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt
            curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
        elif command -v pacman >/dev/null 2>&1; then
            sudo pacman -S --noconfirm azure-cli &>/dev/null
        else
            log_warn "Skipping Azure CLI install: no supported package manager found"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install azure-cli
    fi
fi

az --version
