#!/usr/bin/env bash
#
# After running this script:
#   1. pyenv is installed
#

# 1. pyenv is installed
export PYENV_ROOT="$HOME/.pyenv"
if not_installed "pyenv"; then

    printf "Installing pyenv...\n"

    # Install pyenv prerequisites
    # see https://github.com/pyenv/pyenv/wiki/common-build-problems
    pyenv_list_file="$install_dir/10-pyenv-pkglist"
    install_file "$pyenv_list_file"

    # Install pyenv
    # see https://github.com/pyenv/pyenv-installer
    run "https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer" \
        "bash"

fi
printf "pyenv is installed, upgrading...\n"
git --git-dir="$PYENV_ROOT/.git" pull
pyenv --version
