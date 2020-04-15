#!/usr/bin/env bash

# pyenv is installed
if not_installed "pyenv"; then

    echo "Installing pyenv..."

    # Install pyenv prerequisites
    # see https://github.com/pyenv/pyenv/wiki/common-build-problems
    pyenv_list_file="$install_dir/10-pyenv-pkglist"
    install_file "$pyenv_list_file"

    # Install pyenv
    # see https://github.com/pyenv/pyenv-installer
    run "https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer" \
        "bash"

fi
echo "pyenv is installed, upgrading..."
git --git-dir="$PYENV_ROOT/.git" fetch -q
git --git-dir="$PYENV_ROOT/.git" rebase -q --autostash FETCH_HEAD

pyenv --version
