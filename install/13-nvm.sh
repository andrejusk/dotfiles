#!/usr/bin/env bash

# nvm is installed
if not_installed "nvm"; then

    printf "Installing nvm...\n"

    # Install nvm
    run "https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.2/install.sh" \
        "bash"
    source "$NVM_DIR/nvm.sh"
    nvm alias default lts
    nvm default

fi

printf "nvm is installed, upgrading...\n"
git --git-dir="$NVM_DIR/.git" fetch -q
git --git-dir="$NVM_DIR/.git" rebase -q --autostash FETCH_HEAD

nvm --version
node --version
npm --version
