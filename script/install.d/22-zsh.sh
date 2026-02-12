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

# warn about legacy oh-my-zsh directory
if [ -d "$HOME/.oh-my-zsh" ]; then
    log_warn "Legacy ~/.oh-my-zsh directory found. Remove with: rm -rf ~/.oh-my-zsh"
fi

# migrate zoxide database from z if available
if command -v zoxide &>/dev/null && [ -f "$HOME/.z" ]; then
    log_info "Importing z database into zoxide..."
    zoxide import --from z "$HOME/.z" 2>/dev/null || true
fi

# change default shell to zsh
if [[ "$SHELL" != *zsh ]]; then
    sudo chsh -s "$(command -v zsh)" "$(whoami)"
    sudo usermod -s "$(command -v zsh)" "$(whoami)"
fi
