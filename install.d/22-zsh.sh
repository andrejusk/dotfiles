#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Configure zsh shell.
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

# change default shell to zsh
if [[ "$SHELL" != *zsh ]]; then
    sudo chsh -s "$(command -v zsh)" "$(whoami)"
    sudo usermod -s "$(command -v zsh)" "$(whoami)"
fi

log_pass "zsh configured"
zsh --version | log_quote

