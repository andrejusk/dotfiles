#!/usr/bin/env sh

state_dir="${XDG_RUNTIME_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/tmux}"
pid_file="$state_dir/theme-watcher.pid"
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
watcher="$script_dir/theme-watcher"
events="$state_dir/theme-watcher.$$.events"
observer_pid=""

mkdir -p "$state_dir" 2>/dev/null || exit 0

if [ -r "$pid_file" ]; then
    old_pid=$(cat "$pid_file")
    case $old_pid in
        '' | *[!0-9]*) ;;
        *)
            if kill -0 "$old_pid" 2>/dev/null; then
                kill "$old_pid" 2>/dev/null || true
                attempts=0
                while kill -0 "$old_pid" 2>/dev/null && [ "$attempts" -lt 20 ]; do
                    sleep 0.05
                    attempts=$((attempts + 1))
                done
            fi
            ;;
    esac
fi
printf '%s\n' "$$" > "$pid_file" || exit 0

cleanup() {
    if [ -n "$observer_pid" ]; then
        kill "$observer_pid" 2>/dev/null || true
    fi
    rm -f "$events"
    if [ "$(cat "$pid_file" 2>/dev/null)" = "$$" ]; then
        rm -f "$pid_file"
    fi
    tmux set-option -gu @dots_theme_watcher 2>/dev/null || true
}

trap cleanup EXIT
trap 'exit 0' HUP INT TERM

mkfifo "$events" || exit 0

if [ -x "$watcher" ]; then
    "$watcher" > "$events" &
elif command -v notifyutil >/dev/null 2>&1; then
    notifyutil -w AppleInterfaceThemeChangedNotification > "$events" &
else
    exit 0
fi
observer_pid=$!

while IFS= read -r _notification; do
    # The distributed notification can arrive just before defaults updates.
    sleep 0.1
    "$script_dir/sync-theme.sh"
done < "$events"
