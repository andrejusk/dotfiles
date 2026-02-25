#!/usr/bin/env bash
# Network indicator for tmux status bar.
# Pings 1.1.1.1 to measure latency, detects wired vs wifi.
# Caches result for 10s to avoid excessive pinging.

cache="${TMPDIR:-/tmp}/.tmux_network_cache"

# Return cached result if fresh (<10s old)
if [[ -f "$cache" ]]; then
    age=$(( $(date +%s) - $(stat -f%m "$cache" 2>/dev/null || stat -c%Y "$cache" 2>/dev/null || echo 0) ))
    if (( age < 10 )); then
        cat "$cache"
        exit 0
    fi
fi

# Detect connection type
wired=1
if [[ "$(uname)" == "Darwin" ]]; then
    iface=$(route -n get default 2>/dev/null | awk '/interface:/{print $2}')
    if networksetup -listallhardwareports 2>/dev/null | grep -A1 'Wi-Fi' | grep -q "$iface"; then
        wired=""
    fi
else
    iface=$(ip route show default 2>/dev/null | awk '{print $5; exit}')
    [[ -d "/sys/class/net/${iface}/wireless" ]] && wired=""
fi

# Measure latency
ms=""
if [[ "$(uname)" == "Darwin" ]]; then
    ms=$(ping -c1 -t1 1.1.1.1 2>/dev/null | awk '/time=/{gsub(/.*time=/,""); printf "%.0f", $1}')
else
    ms=$(ping -c1 -W1 1.1.1.1 2>/dev/null | awk '/time=/{gsub(/.*time=/,""); printf "%.0f", $1}')
fi

# Pick icon: wired 󰈀 vs wifi 󰤨
if [[ -n "$wired" ]]; then
    icon="󰈀"
else
    icon="󰤨"
fi

if [[ -z "$ms" ]]; then
    result="#[fg=#F40404]󰤭 --#[default]"
elif (( ms <= 50 )); then
    result="#[fg=#808080]${icon} ${ms}ms#[default]"
elif (( ms <= 150 )); then
    result="#[fg=#f88c14]${icon} ${ms}ms#[default]"
else
    result="#[fg=#F40404]${icon} ${ms}ms#[default]"
fi

echo "$result" | tee "$cache"
