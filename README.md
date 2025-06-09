# andrejusk/dotfiles

[![Dotfiles CI status badge](https://github.com/andrejusk/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/andrejusk/dotfiles/actions/workflows/ci.yml)

A collection of dotfiles and install scripts
to set up my development environment
🛠️ 📂️ 🚀

## Usage

A local repository can be installed and updated by running:

    ./install

A specific script can be installed by running:

    ./install script1 script2 ...

### Automated setup

This repository can be installed without a local copy
by invoking the `setup-new` script directly via `curl`:

    # Inspect source
    curl -s https://raw.githubusercontent.com/andrejusk/dotfiles/HEAD/script/setup-new | less

    # Run
    curl -s https://raw.githubusercontent.com/andrejusk/dotfiles/HEAD/script/setup-new | bash
