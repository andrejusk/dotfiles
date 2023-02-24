#!/usr/bin/env bash
nvm_version="v0.38.0"
if ! bin_in_path "nvm"; then
    download_run "https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_version}/install.sh" \
        "bash"
fi

[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

nvm --version
nvm alias default lts/fermium
nvm install lts/fermium
nvm use lts/fermium

node --version

yarn --version

for dep in $(jq -r ".node_dependencies[]" $CONFIG); do
    yarn global add $dep
    yarn global upgrade $dep
done
