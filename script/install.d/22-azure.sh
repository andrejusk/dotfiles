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
            if command -v yay >/dev/null 2>&1; then
                yay -S --noconfirm azure-cli-bin || log_warn "AUR install failed for azure-cli-bin"
            else
                log_warn "Skipping Azure CLI: no AUR helper found"
            fi
        else
            log_warn "Skipping Azure CLI install: no supported package manager found"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install azure-cli
    fi
fi

az --version
