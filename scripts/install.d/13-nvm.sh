#!/usr/bin/env bash
nvm_version="v0.38.0"
if ! bin_in_path "nvm"; then
    download_run "https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_version}/install.sh" \
        "bash"
fi

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

nvm --version
nvm install node
nvm use node

node --version
