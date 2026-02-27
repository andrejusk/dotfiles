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

tmux -V | log_quote

# Compile screensaver
if command -v cc &> /dev/null && [ -f "$HOME/.tmux/donut.c" ]; then
    cc -O2 -o "$HOME/.tmux/donut" "$HOME/.tmux/donut.c" -lm
    log_pass "Compiled donut screensaver"
fi

