#!/usr/bin/env bash
#
# After running this script:
#   1. python3 and pip3 are installed
#

# 1. python3 and pip3 are installed
if not_installed "pip3"; then

    printf "Installing python3 and pip3...\n"

    pyenv install 3.7.0
    pyenv global 3.7.0
    pyenv local 3.7.0

fi
printf "python3 and pip3 are installed, upgrading...\n"
pip3 install --upgrade pip
python3 --version
pip3 --version
