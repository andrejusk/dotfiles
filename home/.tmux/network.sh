#!/usr/bin/env bash
# Network indicator for tmux status bar.
# Pings 1.1.1.1 to measure latency, detects wired vs wifi, and tracks active bandwidth.
# Latency and route cached for 10s to avoid excessive pinging; traffic sampled per-tick.
# Emits a full rounded capsule (normal muted or amber highlight when offline/high ping).
# Traffic indicator appears dynamically only when transfer rate >= 50 KB/s (Option 2: Active-Only).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
theme="${DOTS_THEME:-$("$SCRIPT_DIR/theme.sh" 2>/dev/null || echo "dark")}"
state_dir="${XDG_RUNTIME_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/tmux}"
umask 077
mkdir -p "$state_dir" 2>/dev/null || exit 0
state_file="$state_dir/network"

now=$(date +%s)

# Load previous state
ping_time=0
ms=""
wired=1
iface=""
prev_time=0
prev_rx=0
prev_tx=0
prev_rx_rate=0
prev_tx_rate=0
last_active=0
last_active_rx=0
last_active_tx=0

if [[ -r "$state_file" ]]; then
    while IFS='=' read -r key value; do
        case "$key" in
            ping_time|prev_time|last_active)
                [[ "$value" =~ ^[0-9]{1,10}$ ]] && printf -v "$key" '%s' "$value" ;;
            prev_rx|prev_tx|prev_rx_rate|prev_tx_rate)
                [[ "$value" =~ ^[0-9]{1,19}$ ]] && printf -v "$key" '%s' "$value" ;;
            last_active_rx|last_active_tx)
                [[ "$value" =~ ^[01]$ ]] && printf -v "$key" '%s' "$value" ;;
            ms)
                [[ -z "$value" || "$value" =~ ^[0-9]{1,6}$ ]] && ms="$value" ;;
            wired)
                [[ -z "$value" || "$value" == "1" ]] && wired="$value" ;;
            iface)
                [[ -z "$value" || "$value" =~ ^[[:alnum:]_.:-]+$ ]] && iface="$value" ;;
        esac
    done < "$state_file"
fi

# Refresh ping and interface info every 10s (or if uninitialized)
if (( now - ping_time >= 10 || ping_time == 0 )); then
    ping_time=$now
    wired=1
    if [[ "$(uname)" == "Darwin" ]]; then
        iface=$(route -n get default 2>/dev/null | awk '/interface:/{print $2}')
        if [[ -z "$iface" ]]; then
            wired=""
        elif networksetup -listallhardwareports 2>/dev/null | grep -A1 'Wi-Fi' | grep -q "$iface"; then
            wired=""
        fi
        ms=$(ping -c1 -t1 1.1.1.1 2>/dev/null | awk '/time=/{gsub(/.*time=/,""); printf "%.0f", $1}')
    else
        iface=$(ip route show default 2>/dev/null | awk '{print $5; exit}')
        [[ -z "$iface" || -d "/sys/class/net/${iface}/wireless" ]] && wired=""
        ms=$(ping -c1 -W1 1.1.1.1 2>/dev/null | awk '/time=/{gsub(/.*time=/,""); printf "%.0f", $1}')
    fi
fi

# Sample byte counters
rx=0
tx=0
if [[ -n "$iface" ]]; then
    if [[ "$(uname)" == "Darwin" ]]; then
        read -r rx tx < <(netstat -ibn -I "$iface" 2>/dev/null | awk 'NR>1 && $1 ~ /^[a-z0-9]+$/ {print $7, $10; exit}')
    else
        if [[ -f "/sys/class/net/$iface/statistics/rx_bytes" ]]; then
            rx=$(< "/sys/class/net/$iface/statistics/rx_bytes")
            tx=$(< "/sys/class/net/$iface/statistics/tx_bytes")
        elif [[ -f /proc/net/dev ]]; then
            read -r rx tx < <(awk -v iface="$iface:" '$1 == iface {print $2, $10}' /proc/net/dev)
        fi
    fi
fi

# Calculate rate (bytes/sec)
rx_rate=$prev_rx_rate
tx_rate=$prev_tx_rate
dt=$(( now - prev_time ))

if (( dt >= 1 && prev_rx > 0 && rx >= prev_rx )); then
    rx_rate=$(( (rx - prev_rx) / dt ))
    tx_rate=$(( (tx - prev_tx) / dt ))
    prev_rx=$rx
    prev_tx=$tx
    prev_time=$now
    prev_rx_rate=$rx_rate
    prev_tx_rate=$tx_rate
elif (( prev_rx == 0 || rx < prev_rx )); then
    prev_rx=$rx
    prev_tx=$tx
    prev_time=$now
fi

# Check active traffic (threshold: 50 KB/s = 51200 bytes/sec)
rx_active=0
tx_active=0
(( rx_rate >= 51200 )) && rx_active=1
(( tx_rate >= 51200 )) && tx_active=1

if (( rx_active || tx_active )); then
    last_active=$now
    last_active_rx=$rx_active
    last_active_tx=$tx_active
fi

# Persist state
state_tmp="$state_file.$$.tmp"
printf 'ping_time=%s\nms=%s\nwired=%s\niface=%s\nprev_time=%s\nprev_rx=%s\nprev_tx=%s\nprev_rx_rate=%s\nprev_tx_rate=%s\nlast_active=%s\nlast_active_rx=%s\nlast_active_tx=%s\n' \
    "$ping_time" "$ms" "$wired" "$iface" "$prev_time" "$prev_rx" "$prev_tx" "$prev_rx_rate" "$prev_tx_rate" "$last_active" "$last_active_rx" "$last_active_tx" > "$state_tmp" \
    && mv -f "$state_tmp" "$state_file"

# Pure bash speed formatter (0 subshells)
format_speed() {
    local b=$1
    if (( b >= 1073741824 )); then
        local g=$(( b * 10 / 1073741824 ))
        echo "$(( g / 10 )).$(( g % 10 ))G"
    elif (( b >= 1048576 )); then
        local m=$(( b * 10 / 1048576 ))
        echo "$(( m / 10 )).$(( m % 10 ))M"
    elif (( b >= 1024 )); then
        echo "$(( (b + 512) / 1024 ))K"
    elif (( b > 0 )); then
        echo "${b}B"
    else
        echo "-B"
    fi
}

# Pick icon: wired 󰈀 vs wifi 󰤨
if [[ -n "$wired" ]]; then
    icon="󰈀"
else
    icon="󰤨"
fi

# Theme palette colors
if [[ "$theme" == "light" ]]; then
    c_bg="#E0D8C0"
    c_base="#[fg=#506888]"
    c_rx="#[fg=#1A8A72]"
    c_tx="#[fg=#3C5C94]"
    c_warn_bg="#B46400"
    c_warn_fg="#[fg=#F6F0DE]#[bold]"
else
    c_bg="#1A1A1A"
    c_base="#[fg=#808080]"
    c_rx="#[fg=#2CB494]"
    c_tx="#[fg=#7290B8]"
    c_warn_bg="#F88C14"
    c_warn_fg="#[fg=#1A1A1A]#[bold]"
fi

# Debounce traffic indicator for 3s after activity ceases, showing -B/idle rate
speed_str=""
if (( now - last_active <= 3 && last_active > 0 )); then
    show_rx=$rx_active
    show_tx=$tx_active
    if (( !rx_active && !tx_active )); then
        show_rx=$last_active_rx
        show_tx=$last_active_tx
    fi

    if (( show_rx && show_tx )); then
        speed_str="${c_rx}↓$(format_speed "$rx_rate") ${c_tx}↑$(format_speed "$tx_rate")"
    elif (( show_rx )); then
        speed_str="${c_rx}↓$(format_speed "$rx_rate")"
    elif (( show_tx )); then
        speed_str="${c_tx}↑$(format_speed "$tx_rate")"
    fi
fi

warn=""
if [[ -z "$ms" ]]; then
    text="󰤭 --"
    warn=1
else
    if [[ -n "$speed_str" ]]; then
        text="${speed_str}  ${c_base}${icon} ${ms}ms"
    else
        text="${c_base}${icon} ${ms}ms"
    fi
    (( ms > 150 )) && warn=1
fi

if [[ -n "$warn" ]]; then
    result="#[fg=${c_warn_bg}]#[bg=${c_warn_bg}]${c_warn_fg} ${text} #[fg=${c_warn_bg}]#[bg=default] "
else
    result="#[fg=${c_bg}]#[bg=${c_bg}] ${text} #[fg=${c_bg}]#[bg=default] "
fi

echo "$result"
