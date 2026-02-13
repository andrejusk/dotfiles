#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Configure zsh shell with direct plugin management.
#

# install zsh
if ! command -v zsh &> /dev/null; then
    case "$DOTS_PKG" in
        apt)
            sudo apt-get install -qq zsh
            ;;
        pacman)
            sudo pacman -S --noconfirm zsh
            ;;
        brew)
            brew install zsh
            ;;
        *)
            log_warn "Skipping zsh install: no supported package manager found"
            return 0
            ;;
    esac
fi

zsh --version

# plugin directory (XDG compliant)
PLUGIN_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
mkdir -p "$PLUGIN_DIR"

# install zsh-autosuggestions
if [ ! -d "$PLUGIN_DIR/zsh-autosuggestions" ]; then
    git clone -q \
        https://github.com/zsh-users/zsh-autosuggestions.git \
        "$PLUGIN_DIR/zsh-autosuggestions"
fi

# install zsh-syntax-highlighting
if [ ! -d "$PLUGIN_DIR/zsh-syntax-highlighting" ]; then
    git clone -q \
        https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "$PLUGIN_DIR/zsh-syntax-highlighting"
fi

# change default shell to zsh
if [[ "$SHELL" != *zsh ]]; then
    sudo chsh -s "$(command -v zsh)" "$(whoami)"
    sudo usermod -s "$(command -v zsh)" "$(whoami)"
fi

log_pass "zsh configured"
