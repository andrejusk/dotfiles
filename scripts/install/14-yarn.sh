#!/usr/bin/env bash
if not_installed "yarn"; then
    add_key https://dl.yarnpkg.com/debian/pubkey.gpg
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    update 
    sudo apt install --no-install-recommends yarn
fi

yarn --version
