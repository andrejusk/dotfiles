#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Clean up after installation.
#

if [[ "$OSTYPE" == "darwin"* ]]; then
    brew cleanup
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get autoremove -qq
        sudo apt-get clean -qq
    elif command -v pacman >/dev/null 2>&1; then
        # Remove orphans if any (ignore error if none)
        if pacman -Qtdq >/dev/null 2>&1; then
            sudo pacman -Rns --noconfirm $(pacman -Qtdq) || true
        fi
        # Clear package cache without interactive prompt
        yes | sudo pacman -Scc >/dev/null 2>&1 || true
    else
        log_warn "Skipping cleanup: no supported package manager found"
    fi
fi

log_pass "Cleanup completed successfully!"
