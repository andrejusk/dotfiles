#!/usr/bin/env bash
#
# After running this script:
#   1. nvm is installed
#

# 1. nvm is installed
if not_installed "nvm"; then

    printf "Installing nvm...\n"

    # Install nvm
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.2/install.sh | bash
    refresh

fi
printf "nvm is installed, upgrading...\n"
git --git-dir="$NVM_DIR/.git" pull
nvm update --lts node
nvm update node
nvm update npm
nvm --version
node --version
npm --version
