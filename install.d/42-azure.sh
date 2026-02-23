#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#  Install Azure CLI.
#

# Skip in Codespaces (project-specific tool)
[[ "$DOTS_ENV" == "codespaces" ]] && { log_skip "Codespaces"; return 0; }

if ! command -v az &>/dev/null; then
    case "$DOTS_PKG" in
        apt)
            # https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt
            curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
            ;;
        pacman)
            sudo pacman -S --noconfirm azure-cli &>/dev/null
            ;;
        brew)
            brew install azure-cli
            ;;
        *)
            log_warn "Skipping Azure CLI install: no supported package manager found"
            ;;
    esac
fi

az --version | log_quote
log_pass "Azure CLI installed"
