#!/usr/bin/env sh

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
theme=$("$script_dir/theme.sh") || exit 1
current=$(tmux show-environment -g DOTS_THEME 2>/dev/null)
current=${current#DOTS_THEME=}

[ "$theme" = "$current" ] && exit 0

tmux set-environment -g DOTS_THEME "$theme"
tmux source-file "$HOME/.tmux.conf"

tmux list-panes -a -F '#{pane_pid} #{@dots_theme_listener}' |
    while read -r pane_pid listener; do
        [ "$listener" = 1 ] || continue
        kill -USR1 "$pane_pid" 2>/dev/null || true
    done
