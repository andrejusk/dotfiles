#!/usr/bin/env bash
# Tab name for tmux automatic-rename.
# Usage: tab-name.sh <command> <dirname>
# Shows dirname for shells, command for everything else. Truncates at 15 with ….

cmd="$1"
dir="$2"
max=15

case "$cmd" in
    zsh|bash|fish|sh) name="$dir" ;;
    *) name="$cmd" ;;
esac

if (( ${#name} > max )); then
    echo "${name:0:$max}…"
else
    echo "$name"
fi
