#!/usr/bin/env bash
export PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring

if ! bin_in_path "pip3"; then
    pyenv install 3.9.0
    pyenv global 3.9.0
fi

pip install --upgrade pip
pip3 install --upgrade pip
python3 --version
pip3 --version

for dep in `jq -r ".pip_dependencies[]" $CONFIG`; do
    pip3 install --upgrade $dep
done
