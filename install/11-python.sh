#!/usr/bin/env bash
source "$(dirname $0)/utils.sh"

# python3 and pip3 are installed
if not_installed "pip3"; then

    echo "Installing python3 and pip3..."

    pyenv install 3.7.0
    pyenv global 3.7.0

fi
echo "python3 and pip3 are installed, upgrading..."
pip3 install --upgrade pip
python3 --version
pip3 --version
