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

# change default shell to zsh. chsh works on macOS and Linux; usermod is a
# Linux-only fallback (absent on macOS — an unguarded call aborts ./install
# under set -e) and may be missing on minimal distros (busybox/Alpine/iSH).
if [[ "$SHELL" != *zsh ]]; then
    sudo chsh -s "$(command -v zsh)" "$(whoami)"
    if [[ "$DOTS_OS" == "linux" ]] && command -v usermod &>/dev/null; then
        sudo usermod -s "$(command -v zsh)" "$(whoami)"
    fi
fi

log_pass "zsh configured"
zsh --version | log_quote

