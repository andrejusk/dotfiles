#!/usr/bin/env bash
source "$(dirname $0)/utils.sh"
export PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring

# python3 and pip3 are installed
if not_installed "pip3"; then

    echo "Installing python3 and pip3..."

    pyenv install 3.7.0
    pyenv global 3.7.0
    refresh

fi
echo "python3 and pip3 are installed, upgrading..."
pip install --upgrade pip
pip3 install --upgrade pip
python3 --version
pip3 --version
