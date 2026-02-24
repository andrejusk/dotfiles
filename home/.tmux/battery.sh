#!/usr/bin/env bash
# Battery indicator for tmux status bar.
# Shows percentage only when on battery; amber when <=20%.

pct=""
charging=""

if command -v pmset &>/dev/null; then
    # macOS
    info=$(pmset -g batt)
    pct=$(echo "$info" | grep -o '[0-9]\+%' | head -1 | tr -d '%')
    echo "$info" | grep -q 'AC Power' && charging=1
elif [[ -f /sys/class/power_supply/BAT0/capacity ]]; then
    # Linux
    pct=$(cat /sys/class/power_supply/BAT0/capacity)
    status=$(cat /sys/class/power_supply/BAT0/status)
    [[ "$status" == "Charging" || "$status" == "Full" ]] && charging=1
fi

[[ -z "$pct" ]] && exit 0

if [[ -n "$charging" ]]; then
    echo "#[fg=#808080]AC#[default]"
elif (( pct <= 20 )); then
    echo "#[fg=#f88c14,bold]${pct}%#[default]"
else
    echo "#[fg=#808080]${pct}%#[default]"
fi
