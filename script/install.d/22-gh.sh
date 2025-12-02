#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install GitHub CLI.
#

if ! command -v gh &>/dev/null; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get >/dev/null 2>&1; then
            # https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian-ubuntu-linux-raspberry-pi-os-apt
            sudo mkdir -p -m 755 /etc/apt/keyrings && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null &&
                sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg &&
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
                sudo apt-get update -qq &&
                sudo apt-get install -qq gh
        elif command -v pacman >/dev/null 2>&1; then
            sudo pacman -S --noconfirm github-cli
        else
            log_warn "Skipping GitHub CLI install: no supported package manager found"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install gh
    fi
fi

gh --version
