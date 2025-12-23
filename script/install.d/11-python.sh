#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Configure Python.
#

# Skip in Codespaces (use pre-installed Python)
[[ "$DOTS_ENV" == "codespaces" ]] && { log_pass "Skipping in Codespaces"; return 0; }

export PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring

local version="3.14.2"

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
    case "$DOTS_PKG" in
        apt)
            sudo apt-get install -qq pipx
            ;;
        pacman)
            sudo pacman -S --noconfirm python-pipx
            ;;
        brew)
            brew install pipx
            ;;
        *)
            log_warn "Skipping pipx install: no supported package manager found"
            ;;
    esac
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
