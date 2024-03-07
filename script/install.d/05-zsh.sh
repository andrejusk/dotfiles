#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Configure zsh shell.
#

# install zsh
if ! command -v zsh &> /dev/null; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get install -qq zsh
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install zsh
    fi
fi

zsh --version

# install oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
if [ ! -d "$ZSH" ]; then
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# install zsh-syntax-highlighting
export ZSH_SYNTAX_HIGHLIGHTING="$ZSH/custom/plugins/zsh-syntax-highlighting"
if [ ! -d "$ZSH_SYNTAX_HIGHLIGHTING" ]; then
    git clone -q https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_SYNTAX_HIGHLIGHTING
fi

#install zsh-autosuggestions
export ZSH_AUTOSUGGESTIONS="$ZSH/custom/plugins/zsh-autosuggestions"
if [ ! -d "$ZSH_AUTOSUGGESTIONS" ]; then
    git clone -q https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_AUTOSUGGESTIONS
fi

# install powerlevel10k
export POWERLEVEL10K="$ZSH/custom/themes/powerlevel10k"
if [ ! -d "$POWERLEVEL10K" ]; then
    git clone -q --depth=1 https://github.com/romkatv/powerlevel10k.git $POWERLEVEL10K
fi
