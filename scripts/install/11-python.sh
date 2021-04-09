#!/usr/bin/env bash
export PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring

if not_installed "pip3"; then
    pyenv install 3.9.0
    pyenv global 3.9.0
    refresh
fi

pip install --upgrade pip
pip3 install --upgrade pip
python3 --version
pip3 --version
