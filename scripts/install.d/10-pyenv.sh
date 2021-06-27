#!/usr/bin/env bash
if ! bin_in_path "pyenv"; then
    # see https://github.com/pyenv/pyenv/wiki/common-build-problems
    pyenv_list_file="$INSTALL_DIR/10-pyenv-pkglist"
    install_file "$pyenv_list_file"

    # see https://github.com/pyenv/pyenv-installer
    download_run "https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer" \
        bash
fi

eval "$(pyenv init --path)"

pyenv update

pyenv --version
