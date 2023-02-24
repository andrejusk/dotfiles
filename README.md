# andrejusk/dotfiles

[![Dotfiles CI](https://github.com/andrejusk/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/andrejusk/dotfiles/actions/workflows/ci.yml)

Collection of dotfiles and supporting install scripts
to set up a reproducible development environment

## Installer

Each push to master publishes the setup script, allowing the repo
to be installed by running:

    # Dependencies if running on Debian
    sudo apt update && sudo apt install --no-install-recommends --yes \
        software-properties-common \
        uuid-runtime \
        wget


    # Inspect source
    wget https://raw.githubusercontent.com/andrejusk/dotfiles/HEAD/script/setup -qO - | less

    # One-liner install if running on Ubuntu
    wget https://raw.githubusercontent.com/andrejusk/dotfiles/HEAD/script/setup -qO - | bash

## The Stack

Tested and maintained against Debian bullseye

### Shell

- 🐟 fish (+ fisher)

### Editor

- vscode

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
