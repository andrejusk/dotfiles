# andrejusk/dotfiles

Collection of my dotfiles and supporting install scripts

## Installer

[![Dotfiles publisher](https://github.com/andrejusk/dotfiles/actions/workflows/publish.yml/badge.svg?branch=master)](https://github.com/andrejusk/dotfiles/actions/workflows/publish.yml)

Each push to master publishes the setup script, allowing the repo
to be installed by running:

    # Dependencies if running on Debian
    sudo apt update && sudo apt install --no-install-recommends --yes \
        software-properties-common \
        uuid-runtime \
        wget

    # Inspect source
    wget http://dots.andrejus.dev/setup.sh -qO - | less

    # One-liner install if running on Ubuntu
    wget http://dots.andrejus.dev/setup.sh -qO - | bash

## The Stack

[![Dotfiles CI](https://github.com/andrejusk/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/andrejusk/dotfiles/actions/workflows/ci.yml)

Tested and maintained against Debian buster

### Shells

- 🐟 fish (+ fisher)

### Editors

- vscode
- neovim (+ vim-plug)
- spacemacs

### Languages

- node.js (nvm, yarn)
- python (pyenv, poetry)

### Tools

- git, gh
- docker
- terraform (+ ls)
- gcloud, firebase, awscli
- redis cli
- kubectl
