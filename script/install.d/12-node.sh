#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Configure Node.js.
#

nvm_version="0.39.7"
if ! bin_in_path "nvm"; then
    download_run "https://raw.githubusercontent.com/nvm-sh/nvm/v${nvm_version}/install.sh" \
        "bash"
fi

NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

nvm --version
nvm alias default lts/iron
nvm install lts/iron
nvm use lts/iron

node --version

yarn --version

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    for dep in $(jq -r ".node_dependencies[]" $CONFIG); do
        yarn global add $dep
        yarn global upgrade $dep
    done
fi

unset nvm_version
