#!/usr/bin/env bash
# Battery indicator for tmux status bar.
# 󰚥 AC when full/plugged, 󰂄 charging with %, amber warning capsule when <=20%.
# If no battery is present (e.g. desktop tower, VM), exits with 0 and emits nothing.

pct=""
charging=""
full=""

if command -v pmset &>/dev/null; then
    # macOS
    info=$(pmset -g batt 2>/dev/null)
    pct=$(echo "$info" | grep -o '[0-9]\+%' | head -1 | tr -d '%')
    echo "$info" | grep -q 'AC Power' && charging=1
    echo "$info" | grep -q 'charged\|finishing charge' && full=1
else
    # Linux (handles BAT0, BAT1, battery, etc.)
    for bat in /sys/class/power_supply/BAT* /sys/class/power_supply/bat* /sys/class/power_supply/*battery*; do
        if [[ -f "$bat/capacity" ]]; then
            pct=$(cat "$bat/capacity" 2>/dev/null)
            status=$(cat "$bat/status" 2>/dev/null)
            [[ "$status" == "Charging" ]] && charging=1
            [[ "$status" == "Full" || "$status" == "Not charging" ]] && full=1
            break
        fi
    done
fi

[[ -z "$pct" ]] && exit 0

warn=""
if [[ -n "$full" ]]; then
    text="󰚥 AC"
elif [[ -n "$charging" ]]; then
    text="󰂄 ${pct}%"
elif (( pct <= 10 )); then
    text="󰂎 ${pct}%"
    warn=1
elif (( pct <= 20 )); then
    text="󰁺 ${pct}%"
    warn=1
elif (( pct <= 40 )); then
    text="󰁼 ${pct}%"
elif (( pct <= 60 )); then
    text="󰁾 ${pct}%"
elif (( pct <= 80 )); then
    text="󰂀 ${pct}%"
else
    text="󰁹 ${pct}%"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
theme="${DOTS_THEME:-$("$SCRIPT_DIR/theme.sh" 2>/dev/null || echo "dark")}"

if [[ "$theme" == "light" ]]; then
    if [[ -n "$warn" ]]; then
        echo "#[fg=#B46400]#[bg=#B46400]#[fg=#F6F0DE]#[bold] ${text} #[fg=#B46400]#[bg=default] "
    else
        echo "#[fg=#E0D8C0]#[bg=#E0D8C0]#[fg=#506888] ${text} #[fg=#E0D8C0]#[bg=default] "
    fi
else
    if [[ -n "$warn" ]]; then
        echo "#[fg=#F88C14]#[bg=#F88C14]#[fg=#1A1A1A]#[bold] ${text} #[fg=#F88C14]#[bg=default] "
    else
        echo "#[fg=#1A1A1A]#[bg=#1A1A1A]#[fg=#808080] ${text} #[fg=#1A1A1A]#[bg=default] "
    fi
fi
