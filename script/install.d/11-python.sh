#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Configure Python.
#

export PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring

local version="3.13.7"

if ! pyenv versions --bare | grep -q "$version"; then
    pyenv install "$version"
fi
pyenv global "$version"

pip3 install --quiet --upgrade --user pip
python3 --version
pip3 --version

pip_dependencies=(
    # docker-compose
    # neovim
    # "python-language-server[all]"
    # pyvim
)
installed_packages=$(pip3 list --format=freeze | awk -F'==' '{print $1}')
pip_dependencies=($(comm -13 <(printf "%s\n" "${installed_packages[@]}" | sort) <(printf "%s\n" "${pip_dependencies[@]}" | sort)))

if [ ${#pip_dependencies[@]} -gt 0 ]; then
    pip3 install --quiet --upgrade --user "${pip_dependencies[@]}"
fi

unset installed_packages pip_dependencies PYTHON_KEYRING_BACKEND

local_bin_path="$HOME/.local/bin"
if [[ ":$PATH:" != *":$local_bin_path:"* ]]; then
    export PATH="$local_bin_path:$PATH"
fi
mkdir -p ~/.local/bin
unset local_bin_path

if ! command -v pipx &>/dev/null; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get >/dev/null 2>&1; then
            sudo apt-get install -qq pipx
        elif command -v pacman >/dev/null 2>&1; then
            sudo pacman -S --noconfirm python-pipx
        else
            log_warn "Skipping pipx install: no apt-get or pacman found"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install pipx
    fi
fi

echo "pipx $(pipx --version)"

if ! command -v poetry &>/dev/null; then
    pipx install poetry
fi

poetry --version

POETRY_PLUGIN="$ZSH/custom/plugins/poetry"
if [ ! -d "$POETRY_PLUGIN" ]; then
    mkdir -p "$POETRY_PLUGIN"
    poetry completions zsh > "$POETRY_PLUGIN/_poetry"
fi
