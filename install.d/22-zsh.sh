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

# Change the default shell once using the platform-native command. Running both
# chsh and usermod repeats the same account database update on Linux.
current_shell="${SHELL:-}"
if [[ "$DOTS_OS" == "linux" ]] && command -v getent &>/dev/null; then
    current_shell=$(getent passwd "$(whoami)" | cut -d: -f7)
fi

if [[ "$current_shell" != *zsh ]]; then
    if [[ "$DOTS_OS" == "linux" ]] && command -v usermod &>/dev/null; then
        sudo usermod -s "$(command -v zsh)" "$(whoami)"
    else
        sudo chsh -s "$(command -v zsh)" "$(whoami)"
    fi
fi

unset current_shell

log_pass "zsh configured"
zsh --version | log_quote
