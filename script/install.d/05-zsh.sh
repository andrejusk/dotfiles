#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Configure zsh shell.
#

# install zsh
if ! command -v zsh &> /dev/null; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get >/dev/null 2>&1; then
            sudo apt-get install -qq zsh
        elif command -v pacman >/dev/null 2>&1; then
            sudo pacman -S --noconfirm zsh
        else
            log_warn "Skipping zsh install: no supported package manager found"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install zsh
    fi
fi

zsh --version

# install oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
if [ ! -d "$ZSH" ]; then
    # https://github.com/ohmyzsh/ohmyzsh#unattended-install
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
export ZSH_CUSTOM="$ZSH/custom"

# install zsh-syntax-highlighting
export ZSH_SYNTAX_HIGHLIGHTING="$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
if [ ! -d "$ZSH_SYNTAX_HIGHLIGHTING" ]; then
    git clone -q \
        https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "$ZSH_SYNTAX_HIGHLIGHTING"
fi

# install zsh-autosuggestions
export ZSH_AUTOSUGGESTIONS="$ZSH_CUSTOM/plugins/zsh-autosuggestions"
if [ ! -d "$ZSH_AUTOSUGGESTIONS" ]; then
    git clone -q \
        https://github.com/zsh-users/zsh-autosuggestions.git \
        "$ZSH_AUTOSUGGESTIONS"
fi

# change default shell to zsh
if [[ "$SHELL" != *zsh ]]; then
    sudo chsh -s "$(command -v zsh)" "$(whoami)"
    sudo usermod -s "$(command -v zsh)" "$(whoami)"
fi
