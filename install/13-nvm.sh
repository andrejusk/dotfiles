#!/usr/bin/env bash
source "$(dirname $0)/utils.sh"

# nvm is installed
if not_installed "nvm"; then

    printf "Installing nvm...\n"

    # Install nvm
    mkdir -p $NVM_DIR
    run "https://raw.githubusercontent.com/nvm-sh/nvm/v0.36.0/install.sh" \
        "bash"
    source "$NVM_DIR/nvm.sh"
    nvm alias default node
    nvm install node

fi

printf "nvm is installed, upgrading...\n"
run "https://raw.githubusercontent.com/nvm-sh/nvm/v0.36.0/install.sh" \
    "bash"

nvm --version
nvm use node
node --version
