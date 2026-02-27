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

# In Codespaces, show friendly name without trailing random ID
# Codespace names: "adjective-noun-id" where id is alphanumeric gibberish
if [[ -n "$CODESPACE_NAME" ]]; then
    friendly="${CODESPACE_NAME%-*}"
    # If no hyphen was found, use full name
    [[ "$friendly" == "$CODESPACE_NAME" ]] && friendly="$CODESPACE_NAME"
    echo "cs:${friendly}"
    exit 0
fi

if (( ${#name} > max )); then
    echo "${name:0:$max}…"
else
    echo "$name"
fi
