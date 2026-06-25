#!/bin/sh
# Reflect Copilot CLI activity on the enclosing tmux window.
#
# Called by ~/.copilot/hooks/hooks.json on Copilot lifecycle events. The state is
# stored as a @copilot_state window option and rendered by window-status-format
# (see ~/.tmux.conf) as an at-a-glance tab icon. Recognised states:
#   working   agent is processing            waiting   response ready, your move
#   question  agent is asking you (ask_user)  error    last turn errored
#   clear     remove the indicator (session ended)
#
# When a response lands (waiting) or a question is raised (question) on a window
# you are NOT currently viewing, the window is also flagged "unread" via a
# @copilot_unread option, which window-status-format paints as a full amber tab
# so it stands out among already-seen tabs. The pane-focus-in hook in
# ~/.tmux.conf clears the flag the moment you view (focus) the tab; a new turn
# (working) or session end (clear) clears it too.
#
# Idempotent. Inside a local tmux it sets the window option; outside one (e.g.
# over SSH in a codespace) it instead rings the terminal bell on turn handover
# so the local tmux can flash the tab. Set COPILOT_STATE_DEBUG=<file> to trace.

[ -n "$COPILOT_STATE_DEBUG" ] && \
    printf '%s state=%-8s pane=%s\n' "$(date '+%H:%M:%S')" "${1:-?}" "${TMUX_PANE:-none}" \
    >> "$COPILOT_STATE_DEBUG"

# Inside a local tmux we set a window option (out-of-band; see ~/.tmux.conf).
# Outside one - e.g. running over SSH in a codespace - we can't reach this tmux
# server, but a terminal bell DOES travel back over SSH. Ring it on turn
# handover so the local tmux flashes the tab (monitor-bell + bell-style).
if [ -z "$TMUX" ] || [ -z "$TMUX_PANE" ]; then
    case "$1" in
        waiting|question|error) printf '\a' > /dev/tty 2>/dev/null ;;
    esac
    exit 0
fi

case "$1" in
    ''|clear)
        tmux set-option -wu -t "$TMUX_PANE" @copilot_state  2>/dev/null
        tmux set-option -wu -t "$TMUX_PANE" @copilot_unread 2>/dev/null
        ;;
    working)
        tmux set-option -w  -t "$TMUX_PANE" @copilot_state working 2>/dev/null
        tmux set-option -wu -t "$TMUX_PANE" @copilot_unread        2>/dev/null
        ;;
    waiting|question)
        tmux set-option -w -t "$TMUX_PANE" @copilot_state "$1" 2>/dev/null
        # Flag as unread only when you're not already looking at this window;
        # otherwise pane-focus-in never fires to clear it and the tab sticks amber.
        [ "$(tmux display-message -p -t "$TMUX_PANE" '#{window_active}' 2>/dev/null)" = "1" ] || \
            tmux set-option -w -t "$TMUX_PANE" @copilot_unread 1 2>/dev/null
        ;;
    *)
        tmux set-option -w -t "$TMUX_PANE" @copilot_state "$1" 2>/dev/null
        ;;
esac

exit 0
