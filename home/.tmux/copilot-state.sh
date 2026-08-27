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
# so the local tmux can flash the tab. An unread local handover also plays a
# sound; set COPILOT_SOUND=off to disable it or COPILOT_SOUND_FILE to override
# the default. Set COPILOT_STATE_DEBUG=<file> to trace.

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

_dots_copilot_sound() {
    case "${COPILOT_SOUND:-on}" in
        0|off|false|no) return ;;
    esac

    sound_file="${COPILOT_SOUND_FILE:-}"
    if command -v afplay >/dev/null 2>&1; then
        [ -n "$sound_file" ] || sound_file="/System/Library/Sounds/Glass.aiff"
        [ -r "$sound_file" ] && {
            afplay -v 0.5 "$sound_file" >/dev/null 2>&1 &
            return
        }
    elif command -v canberra-gtk-play >/dev/null 2>&1; then
        if [ -n "$sound_file" ] && [ -r "$sound_file" ]; then
            canberra-gtk-play -f "$sound_file" >/dev/null 2>&1 &
        else
            canberra-gtk-play -i complete >/dev/null 2>&1 &
        fi
        return
    elif command -v paplay >/dev/null 2>&1; then
        if [ -z "$sound_file" ]; then
            for candidate in \
                /usr/share/sounds/freedesktop/stereo/complete.oga \
                /usr/share/sounds/freedesktop/stereo/message.oga
            do
                [ -r "$candidate" ] && {
                    sound_file="$candidate"
                    break
                }
            done
        fi
        [ -n "$sound_file" ] && [ -r "$sound_file" ] && {
            paplay "$sound_file" >/dev/null 2>&1 &
            return
        }
    fi

    printf '\a' > /dev/tty 2>/dev/null
}

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
        if [ "$(tmux display-message -p -t "$TMUX_PANE" '#{window_active}' 2>/dev/null)" != "1" ]; then
            tmux set-option -w -t "$TMUX_PANE" @copilot_unread 1 2>/dev/null
            _dots_copilot_sound
        fi
        ;;
    *)
        tmux set-option -w -t "$TMUX_PANE" @copilot_state "$1" 2>/dev/null
        ;;
esac

exit 0
