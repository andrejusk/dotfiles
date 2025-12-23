#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Clean up after installation.
#

case "$DOTS_PKG" in
    brew)
        brew cleanup
        ;;
    apt)
        sudo apt-get autoremove -qq
        sudo apt-get clean -qq
        ;;
    pacman)
        # Remove orphans if any (ignore error if none)
        if pacman -Qtdq >/dev/null 2>&1; then
            sudo pacman -Rns --noconfirm $(pacman -Qtdq) || true
        fi
        # Clear package cache without interactive prompt
        yes | sudo pacman -Scc >/dev/null 2>&1 || true
        ;;
    *)
        log_warn "Skipping cleanup: no supported package manager found"
        return 0
        ;;
esac

log_pass "Cleanup completed successfully!"
