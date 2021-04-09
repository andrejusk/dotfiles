#!/usr/bin/env bash
export PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring
add_path "$HOME/.local/bin"

if not_installed "poetry"; then
    pip3 install --user poetry
fi

pip3 install --upgrade poetry
poetry --version
