#!/usr/bin/env bash
# Battery indicator for tmux status bar.
# 󰚥 AC when full/plugged, 󰂄 charging with %, amber 󰂃 when <=20%.

pct=""
charging=""
full=""

if command -v pmset &>/dev/null; then
    # macOS
    info=$(pmset -g batt)
    pct=$(echo "$info" | grep -o '[0-9]\+%' | head -1 | tr -d '%')
    echo "$info" | grep -q 'AC Power' && charging=1
    echo "$info" | grep -q 'charged\|finishing charge' && full=1
elif [[ -f /sys/class/power_supply/BAT0/capacity ]]; then
    # Linux
    pct=$(cat /sys/class/power_supply/BAT0/capacity)
    status=$(cat /sys/class/power_supply/BAT0/status)
    [[ "$status" == "Charging" ]] && charging=1
    [[ "$status" == "Full" || "$status" == "Not charging" ]] && full=1
fi

[[ -z "$pct" ]] && exit 0

if [[ -n "$full" ]]; then
    echo "#[fg=#808080]󰚥 AC#[default]"
elif [[ -n "$charging" ]]; then
    echo "#[fg=#808080]󰂄 ${pct}%#[default]"
elif (( pct <= 10 )); then
    echo "#[fg=#F88C14,bold]󰂎 ${pct}%#[default]"
elif (( pct <= 20 )); then
    echo "#[fg=#F88C14,bold]󰁺 ${pct}%#[default]"
elif (( pct <= 40 )); then
    echo "#[fg=#808080]󰁼 ${pct}%#[default]"
elif (( pct <= 60 )); then
    echo "#[fg=#808080]󰁾 ${pct}%#[default]"
elif (( pct <= 80 )); then
    echo "#[fg=#808080]󰂀 ${pct}%#[default]"
else
    echo "#[fg=#808080]󰁹 ${pct}%#[default]"
fi
