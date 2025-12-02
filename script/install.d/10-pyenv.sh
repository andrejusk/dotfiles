#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Configure pyenv.
#

export PYENV_ROOT="$HOME/.pyenv"
if ! echo "$PATH" | grep -q "$PYENV_ROOT"; then
    export PATH="$PYENV_ROOT/bin:$PATH"
fi
if ! command -v pyenv &>/dev/null; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get >/dev/null 2>&1; then
            # https://github.com/pyenv/pyenv/wiki#suggested-build-environment
            sudo apt-get install -qq build-essential libssl-dev zlib1g-dev \
                libbz2-dev libreadline-dev libsqlite3-dev curl \
                libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

            # see https://github.com/pyenv/pyenv-installer
            bash -c "$(curl -fsSL https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer)"
        elif command -v pacman >/dev/null 2>&1; then
            # Prefer native packages if available; otherwise install build deps then use installer
            if ! sudo pacman -Qi pyenv >/dev/null 2>&1; then
                sudo pacman -S --noconfirm --needed base-devel openssl zlib-ng-compat bzip2 readline sqlite xz tk libffi curl
                bash -c "$(curl -fsSL https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer)"
            else
                sudo pacman -S --noconfirm --needed pyenv pyenv-virtualenv
            fi
        else
            log_warn "Skipping pyenv install: no supported package manager found"
        fi
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
            "$virtualenv_path"
    fi
    unset virtualenv_path
fi

eval "$(pyenv init --path)"

pyenv --version
