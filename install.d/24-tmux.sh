#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install and configure tmux.
#

if ! command -v tmux &> /dev/null; then
    case "$DOTS_PKG" in
        apt)
            sudo apt-get install -qq tmux
            ;;
        pacman)
            sudo pacman -S --noconfirm tmux
            ;;
        brew)
            brew install tmux
            ;;
        *)
            log_warn "Skipping tmux install: no supported package manager found"
            return 0
            ;;
    esac
fi

# Compile screensaver (skip if binary is newer than source)
if command -v cc &> /dev/null && [ -f "$HOME/.tmux/donut.c" ]; then
    if [ ! -f "$HOME/.tmux/donut" ] || [ "$HOME/.tmux/donut.c" -nt "$HOME/.tmux/donut" ]; then
        cc -O2 -o "$HOME/.tmux/donut" "$HOME/.tmux/donut.c" -lm
    fi
fi

log_pass "tmux configured"
tmux -V | log_quote

