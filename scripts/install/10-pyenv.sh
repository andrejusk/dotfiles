#!/usr/bin/env bash
if not_installed "pyenv"; then
    # see https://github.com/pyenv/pyenv/wiki/common-build-problems
    pyenv_list_file="$INSTALL_DIR/10-pyenv-pkglist"
    install_file "$pyenv_list_file"

    # see https://github.com/pyenv/pyenv-installer
    run "https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer" \
        bash
fi

export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

pyenv update

pyenv --version
