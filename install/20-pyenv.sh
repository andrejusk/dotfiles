#!/usr/bin/env bash
#
# After running this script:
#   1. pyenv is installed
#

# 1. pyenv is installed
if not_installed "pyenv"; then

    printf "Installing pyenv...\n"

    # Install pyenv prerequisites
    # see https://github.com/pyenv/pyenv/wiki/common-build-problems
    install make build-essential libssl-dev zlib1g-dev libbz2-dev \
        libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
        xz-utils tk-dev libffi-dev liblzma-dev python-openssl git

    # Install pyenv
    # see https://github.com/pyenv/pyenv-installer
    run https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer bash

    # Add to install path
    export PATH="$HOME/.pyenv/bin:$PATH"

fi
printf "pyenv is installed\n"
