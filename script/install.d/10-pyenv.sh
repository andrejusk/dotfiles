#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Configure pyenv.
#

if ! bin_in_path "pyenv"; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # see https://github.com/pyenv/pyenv/wiki/common-build-problems
        pyenv_list_file="$INSTALL_DIR/10-pyenv-pkglist"
        install_file "$pyenv_list_file"

        # see https://github.com/pyenv/pyenv-installer
        download_run \
            "https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer" \
            bash
e
        unset pyenv_list_file
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
fi

eval "$(pyenv init --path)"

pyenv update

pyenv --version
