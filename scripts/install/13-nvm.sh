#!/usr/bin/env bash
run "https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh" \
    "bash"

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
 
nvm --version
nvm install node
nvm use node

node --version
