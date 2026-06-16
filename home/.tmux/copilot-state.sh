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
# Idempotent and a no-op outside tmux. Set COPILOT_STATE_DEBUG=<file> to trace.

[ -n "$COPILOT_STATE_DEBUG" ] && \
    printf '%s state=%-8s pane=%s\n' "$(date '+%H:%M:%S')" "${1:-?}" "${TMUX_PANE:-none}" \
    >> "$COPILOT_STATE_DEBUG"

# Only act inside a tmux client with a known pane.
[ -n "$TMUX" ] && [ -n "$TMUX_PANE" ] || exit 0

case "$1" in
    ''|clear)
        tmux set-option -wu -t "$TMUX_PANE" @copilot_state 2>/dev/null ;;
    *)
        tmux set-option -w -t "$TMUX_PANE" @copilot_state "$1" 2>/dev/null ;;
esac

exit 0
