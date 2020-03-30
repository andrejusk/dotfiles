#!/usr/bin/env bash

# 1. nvm is installed
if not_installed "nvm"; then

    printf "Installing nvm...\n"

    # Install nvm
    run "https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.2/install.sh" \
        "bash"
    source "$NVM_DIR/nvm.sh"

fi

printf "nvm is installed, upgrading...\n"
git --git-dir="$NVM_DIR/.git" pull
nvm --version
node --version
npm --version
