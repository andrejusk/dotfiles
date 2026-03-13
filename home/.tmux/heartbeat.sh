#!/usr/bin/env bash
# Heartbeat / liveness indicator for tmux status bar.
#
# Pressure-based activity tracking using native tmux signals:
#   Input (keystroke/mouse):  +5 per event
#   Output (command output):  +2 per tick
#   Copy mode (reading):      +2 per tick
#   Decay:                    -1 per tick
#   Score capped at 100, floored at 0.
#
# Counter ticks while score > 0. Resets on tmux restart.
# Outputs a tmux fg color that fades from teal to gray with activity.

SCORE_CAP=100

state="${TMPDIR:-/tmp}/.tmux_heartbeat"
read client_act win_act in_mode tmux_pid <<< \
    "$(tmux display-message -p '#{client_activity} #{window_activity} #{pane_in_mode} #{pid}')"
now=$(date +%s)

# Load previous state
prev_client="" prev_win="" score=0 active_total=0 srv_pid=""
return_at="" return_show=0
[[ -f "$state" ]] && source "$state"

# Reset if tmux server restarted
if [[ "$srv_pid" != "$tmux_pid" ]]; then
    score=0 active_total=0 return_at="" return_show=0
fi

# Detect screensaver/lock gaps (script wasn't running for >10s)
if [[ -f "$state" ]]; then
    last_run=$(stat -f%m "$state" 2>/dev/null || stat -c%Y "$state" 2>/dev/null || echo "$now")
    gap=$(( now - last_run ))
    if (( gap > 10 )); then
        return_at=$now
        return_show=$gap
        score=0
    fi
fi

# Score: check activity signals
if [[ -n "$prev_client" && "$client_act" != "$prev_client" ]]; then
    (( score += 5 ))
fi

if [[ -n "$prev_win" && "$win_act" != "$prev_win" ]]; then
    (( score += 2 ))
fi

if [[ "$in_mode" == "1" ]]; then
    (( score += 2 ))
fi

(( score-- ))
(( score > SCORE_CAP )) && score=$SCORE_CAP
(( score < 0 )) && score=0

(( score > 0 )) && (( active_total++ ))

# Clear return flash after 4s
if [[ -n "$return_at" ]] && (( now - return_at >= 4 )); then
    return_at="" return_show=0
fi

# Persist
printf 'prev_client=%s\nprev_win=%s\nscore=%s\nactive_total=%s\nsrv_pid=%s\nreturn_at=%s\nreturn_show=%s\n' \
    "$client_act" "$win_act" "$score" "$active_total" "$tmux_pid" "$return_at" "$return_show" > "$state"

# Output: tmux color code that fades teal (#2CB494) → gray (#808080)
# Interpolate RGB channels based on score (0-100)
lerp() {
    local from=$1 to=$2 pct=$3
    echo $(( from + (to - from) * pct / 100 ))
}

if [[ -n "$return_at" ]]; then
    printf '#[fg=colour208]'
else
    r=$(lerp 128 44 "$score")
    g=$(lerp 128 180 "$score")
    b=$(lerp 128 148 "$score")
    printf '#[fg=#%02X%02X%02X]' "$r" "$g" "$b"
fi
