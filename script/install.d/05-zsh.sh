#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Configure zsh shell.
#

if ! command -v zsh &> /dev/null; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get install -qq zsh
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install zsh
    fi
fi

zsh --version

# check if oh-my-zsh is installed
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
