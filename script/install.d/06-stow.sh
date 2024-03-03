#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install and run stow.
#

if ! command -v stow &> /dev/null; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get install -qq stow
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install stow
    fi
fi

stow --version

root_dir=$(dirname "$(dirname "$(dirname "$(realpath "$0")")")")

rm -f $HOME/.bash_profile
rm -f $HOME/.bashrc
rm -f $HOME/.gitconfig
rm -f $HOME/.profile
rm -f $HOME/.zshrc
rm -f $HOME/.ssh/config

mkdir -p $HOME/.config
mkdir -p $HOME/.ssh

sudo stow --dir="$root_dir" --target="$HOME" home
sudo stow --dir="$root_dir" --target="$HOME/.config" dot-config
sudo stow --dir="$root_dir" --target="$HOME/.ssh" dot-ssh
