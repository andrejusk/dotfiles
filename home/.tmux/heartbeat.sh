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
#
# Visual (pill with pressure bar):
#   23m ▆  — teal time + teal bar (active, score > 0)
#   5m     — gray time, no bar (paused, score = 0)
#   10s ▃  — amber time + amber bar (returning from away)

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
gaining=0

if [[ -n "$prev_client" && "$client_act" != "$prev_client" ]]; then
    (( score += 5 )); gaining=1
fi

if [[ -n "$prev_win" && "$win_act" != "$prev_win" ]]; then
    (( score += 2 )); gaining=1
fi

if [[ "$in_mode" == "1" ]]; then
    (( score += 2 )); gaining=1
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

# Format seconds to ≤3 chars
fmt() {
    local s=$1
    if (( s < 60 )); then printf "%ds" "$s"
    elif (( s < 3600 )); then printf "%dm" $(( s / 60 ))
    elif (( s < 86400 )); then printf "%dh" $(( s / 3600 ))
    else printf "%dd" $(( s / 86400 )); fi
}

# Pressure bar: block fill (8 levels)
bar() {
    local s=$1
    if (( s >= 88 )); then printf '█'
    elif (( s >= 75 )); then printf '▇'
    elif (( s >= 63 )); then printf '▆'
    elif (( s >= 50 )); then printf '▅'
    elif (( s >= 38 )); then printf '▄'
    elif (( s >= 25 )); then printf '▃'
    elif (( s >= 13 )); then printf '▂'
    elif (( s >= 1 )); then printf '▁'
    else printf ' '; fi
}

# Render: pill with margin (space + bg pill + space)
render() {
    local bar_fg=$1 b=$2 time_fg=$3 txt=$4 len=${#4}
    local rpad=""
    (( len < 3 )) && printf -v rpad "%$(( 3 - len ))s" ""
    printf " #[bg=#1A1A1A,fg=%s] %s%s #[fg=%s]%s#[default] " "$time_fg" "$txt" "$rpad" "$bar_fg" "$b"
}

b=$(bar $score)
if [[ -n "$return_at" ]]; then
    render "colour208" "$b" "colour208" "$(fmt $return_show)"
elif (( score > 0 )); then
    render "#2CB494" "$b" "#2CB494" "$(fmt $active_total)"
else
    render "#808080" " " "#808080" "$(fmt $active_total)"
fi
