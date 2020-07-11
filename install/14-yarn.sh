#!/usr/bin/env bash
source "$(dirname $0)/utils.sh"

# yarn is installed
if not_installed "yarn"; then

    echo "Installing yarn..."

    # Install yarn
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    update 
    sudo apt install --no-install-recommends yarn

fi

echo "yarn is installed"
yarn --version
