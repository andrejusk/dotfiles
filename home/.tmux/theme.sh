#!/usr/bin/env sh
# Resolve the active colour theme (prints "light" or "dark") for tmux.
#
# tmux sources ~/.tmux.conf once, when the server starts. On a tmux-continuum or
# boot restore that server can start with no DOTS_THEME in its environment, so
# trusting the inherited variable silently falls back to the dark theme even in
# light mode. Detect it here instead, mirroring the precedence in ~/.profile:
# explicit DOTS_THEME > COLORFGBG > macOS appearance > dark.

if [ -n "${DOTS_THEME:-}" ]; then
    printf '%s\n' "$DOTS_THEME"
    exit 0
fi

if [ -n "${COLORFGBG:-}" ]; then
    bg=${COLORFGBG##*;}
    case $bg in
        '' | *[!0-9]*) bg=0 ;;
    esac
    if [ "$bg" -ge 7 ]; then
        printf 'light\n'
    else
        printf 'dark\n'
    fi
    exit 0
fi

if [ "$(uname)" = Darwin ]; then
    # AppleInterfaceStyle exists only in Dark mode; its absence means Light.
    if [ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" = Dark ]; then
        printf 'dark\n'
    else
        printf 'light\n'
    fi
    exit 0
fi

printf 'dark\n'
