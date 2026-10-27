#!/usr/bin/env sh
# Resolve the active colour theme (prints "light" or "dark") for tmux.
#
# tmux sources ~/.tmux.conf once, when the server starts. On a tmux-continuum or
# boot restore that server can start with no theme in its environment. DOTS_THEME
# is also the last resolved value cached by tmux, so it must not act as an
# override or the status palette cannot follow later appearance changes.
# This mirrors ~/.profile: explicit override > macOS appearance > COLORFGBG >
# dark.

if [ "$DOTS_THEME_OVERRIDE" = light ] || [ "$DOTS_THEME_OVERRIDE" = dark ]; then
    printf '%s\n' "$DOTS_THEME_OVERRIDE"
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

printf 'dark\n'
