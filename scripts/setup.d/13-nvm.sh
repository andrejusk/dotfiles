#!/usr/bin/env bash

#
# Ensure nvm is installed
# Ensure default node version
# is aliased, installed and active
#


nvm_version=${NVM_VERSION:-"v0.39.1"}
if [ ! -d "$NVM_DIR" ]; then
    echo "Installing nvm $nvm_version..."
    mkdir -p "$NVM_DIR"
    download_run \
        "https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_version}/install.sh" \
        bash
else
    echo "nvm is already installed"
fi

[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
nvm --version

node_version=${NODE_VERSION:-"lts/fermium"}
nvm alias default "$node_version"
nvm install "$node_version"
nvm use "$node_version"

node --version
