# andrejusk/dotfiles

[![Dotfiles CI](https://github.com/andrejusk/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/andrejusk/dotfiles/actions/workflows/ci.yml)

My collection of dotfiles and install scripts
to set up reproducible dev environments

## Usage

A local repository can be installed by running:

    ./script/install

### Automated install

This repository can be installed without a local copy
by invoking the `setup` script directly via `curl`:

    # Inspect source
    curl -s https://raw.githubusercontent.com/andrejusk/dotfiles/HEAD/script/setup | less

    # Run
    curl -s https://raw.githubusercontent.com/andrejusk/dotfiles/HEAD/script/setup | bash

## Features

My dotfiles include configuration for the following tools:

### Shell

- zsh

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
