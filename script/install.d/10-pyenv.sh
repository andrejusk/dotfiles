#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Configure pyenv.
#

if ! command -v "pyenv" &> /dev/null; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # see https://github.com/pyenv/pyenv/wiki/common-build-problems
        ppyenv_packages=(
            build-essential
            libssl-dev
            libbz2-dev
            libreadline-dev
            libsqlite3-dev
            libxml2-dev
            libxmlsec1-dev
            llvm
            libncurses5-dev
            libncursesw5-dev
            xz-utils
            tk-dev
            libffi-dev
            liblzma-dev
            zlib1g-dev
        )
        pyenv_packages=($(comm -13 <(printf "%s\n" "${pyenv_packages[@]}" | sort) <(dpkg --get-selections | awk '{print $1}' | sort)))
        if [ ${#pyenv_packages[@]} -gt 0 ]; then
            sudo apt-get install -qq "${pyenv_packages[@]}"
        fi

        # see https://github.com/pyenv/pyenv-installer
        bash -c "$(curl -fsSL https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer)"

        unset pyenv_packages
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install pyenv
        brew install pyenv-virtualenv
    fi
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    virtualenv_path="$(pyenv root)/plugins/pyenv-virtualenv"
    if [ ! -d "$virtualenv_path" ]; then
        git clone \
            https://github.com/pyenv/pyenv-virtualenv.git \
            $virtualenv_path
    fi
    unset virtualenv_path
fi

eval "$(pyenv init --path)"

pyenv --version
