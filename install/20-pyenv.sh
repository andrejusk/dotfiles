#!/bin/bash
#
# After running this script:
#   1. pyenv is installed
#

# 1. pyenv is installed
if ! hash pyenv 2>/dev/null; then

    printf "Installing pyenv...\n"

    # Install pyenv prerequisites
    # see https://github.com/pyenv/pyenv/wiki/common-build-problems
    sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev \
libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
xz-utils tk-dev libffi-dev liblzma-dev python-openssl git

    # Install pyenv
    # see https://github.com/pyenv/pyenv-installer
    curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash

fi
printf "pyenv is installed\n"
