#!/usr/bin/env bash

#
# Ensure desired version of Python is installed,
# upgrade pip as well as any global packages
#


# Fix pip blocking forever for a keyring to unlock
export PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring

if [[ $(pyenv versions | grep "$PYENV_VERSION") ]]; then
    echo "Python $PYENV_VERSION already present"
else
    echo "Installing Python $PYENV_VERSION..."
    pyenv install $PYENV_VERSION
    pyenv global $PYENV_VERSION
fi
python3 --version

pip install --upgrade pip
pip3 install --upgrade pip
pip3 --version

for dep in $(jq -r ".pip_dependencies[]" $CONFIG); do
    pip3 install --quiet --upgrade $dep
done
