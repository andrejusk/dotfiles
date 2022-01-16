#!/usr/bin/env bash

#
# Ensure pyenv is installed
#


# Ensure pyenv dependencies are installed
if ! bin_in_path "pyenv"; then
    echo "Installing pyenv..."

    # see https://github.com/pyenv/pyenv/wiki/common-build-problems
    pyenv_list_file="$INSTALL_DIR/10-pyenv-pkglist"
    install_file "$pyenv_list_file"

    # see https://github.com/pyenv/pyenv-installer
    download_run \
        "https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer" \
        bash
else
    echo "pyenv is already present"
fi
pyenv --version

# Ensure virtualenv is installed
virtualenv_path="$(pyenv root)/plugins/pyenv-virtualenv"
if [ ! -d "$virtualenv_path" ]; then
    echo "Installing virtualenv..."
    git clone \
        https://github.com/pyenv/pyenv-virtualenv.git \
        $virtualenv_path
else
    echo "virtualenv is already present"
fi

# Ensure pyenv is up-to-date
eval "$(pyenv init --path)"
pyenv update
