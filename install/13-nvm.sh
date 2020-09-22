#!/usr/bin/env bash
source "$(dirname $0)/utils.sh"

# nvm is installed
if not_installed "nvm"; then

    printf "Installing nvm...\n"

    # Install nvm
    run "https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.2/install.sh" \
        "bash"
    source "$NVM_DIR/nvm.sh"
    nvm alias default node
    nvm install node

fi

printf "nvm is installed, upgrading...\n"
git --git-dir="$NVM_DIR/.git" fetch -q
git --git-dir="$NVM_DIR/.git" rebase -q --autostash FETCH_HEAD

nvm --version
nvm use node
node --version
