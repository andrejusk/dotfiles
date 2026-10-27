#!/usr/bin/env bash
# Network indicator for tmux status bar.
# Pings 1.1.1.1 to measure latency, detects wired vs wifi, and tracks active bandwidth.
# Wi-Fi signal strength is sampled from CoreWLAN on macOS or /proc on Linux.
# Latency and route cached for 10s to avoid excessive pinging; traffic sampled per-tick.
# Latency uses a 30-sample rolling mean. The icon flashes during the first
# 12 successful probes, then stays stable while the best estimate keeps updating.
# Offline warnings require 30s of failed pings.
# Emits a full rounded capsule (normal muted or amber highlight when offline/high ping).
# Receive/send arrows stay visible and gain semantic color above 50 KB/s.

# A Codespace exposes a remote virtual interface, not the client's connection,
# and commonly blocks ICMP probes. Do not show a misleading network capsule.
[[ -n "${CODESPACES:-}" ]] && exit 0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
theme="${DOTS_THEME:-$("$SCRIPT_DIR/theme.sh" 2>/dev/null || echo "dark")}"
state_dir="${XDG_RUNTIME_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/tmux}"
umask 077
mkdir -p "$state_dir" 2>/dev/null || exit 0
state_file="$state_dir/network"

now=$(date +%s)
offline_grace=30
latency_min_samples=12
latency_max_samples=30

# Load previous state
ping_time=0
ms=""
latency_samples=""
offline_since=0
wired=1
iface=""
rssi=""
prev_time=0
prev_rx=0
prev_tx=0
prev_rx_rate=0
prev_tx_rate=0

if [[ -r "$state_file" ]]; then
    while IFS='=' read -r key value; do
        case "$key" in
            ping_time|offline_since|prev_time)
                [[ "$value" =~ ^[0-9]{1,10}$ ]] && printf -v "$key" '%s' "$value" ;;
            prev_rx|prev_tx|prev_rx_rate|prev_tx_rate)
                [[ "$value" =~ ^[0-9]{1,19}$ ]] && printf -v "$key" '%s' "$value" ;;
            ms)
                [[ -z "$value" || "$value" =~ ^[0-9]{1,6}$ ]] && ms="$value" ;;
            latency_samples)
                [[ -z "$value" || "$value" =~ ^[0-9]{1,6}(:[0-9]{1,6}){0,29}$ ]] && latency_samples="$value" ;;
            wired)
                [[ -z "$value" || "$value" == "1" ]] && wired="$value" ;;
            iface)
                [[ -z "$value" || "$value" =~ ^[[:alnum:]_.:-]+$ ]] && iface="$value" ;;
            rssi)
                [[ -z "$value" || "$value" =~ ^-[0-9]{1,3}$ ]] && rssi="$value" ;;
        esac
    done < "$state_file"
fi

# Refresh ping and interface info every 10s (or if uninitialized)
ping_refreshed=0
if (( now - ping_time >= 10 || ping_time == 0 )); then
    ping_time=$now
    ping_refreshed=1
    wired=1
    rssi=""
    if [[ "$(uname)" == "Darwin" ]]; then
        iface=$(route -n get default 2>/dev/null | awk '/interface:/{print $2}')
        if [[ -z "$iface" ]]; then
            wired=""
        elif networksetup -listallhardwareports 2>/dev/null | grep -A1 'Wi-Fi' | grep -q "$iface"; then
            wired=""
            if [[ -n "${DOTS_WIFI_RSSI+x}" ]]; then
                rssi=$DOTS_WIFI_RSSI
            elif [[ -x "$SCRIPT_DIR/wifi-rssi" ]]; then
                rssi=$("$SCRIPT_DIR/wifi-rssi" 2>/dev/null)
            fi
            [[ "$rssi" =~ ^-[0-9]{1,3}$ ]] || rssi=""
        fi
        ms=$(ping -c1 -t1 1.1.1.1 2>/dev/null | awk '/time=/{gsub(/.*time=/,""); printf "%.0f", $1}')
    else
        iface=$(ip route show default 2>/dev/null | awk '{print $5; exit}')
        [[ -z "$iface" || -d "/sys/class/net/${iface}/wireless" ]] && wired=""
        if [[ -z "$wired" && -r /proc/net/wireless ]]; then
            rssi=$(awk -v iface="$iface:" '$1 == iface {gsub(/\./, "", $4); print int($4)}' /proc/net/wireless)
            [[ "$rssi" =~ ^-[0-9]{1,3}$ ]] || rssi=""
        fi
        ms=$(ping -c1 -W1 1.1.1.1 2>/dev/null | awk '/time=/{gsub(/.*time=/,""); printf "%.0f", $1}')
    fi
fi

# Add successful probes to the rolling window without reusing cached samples.
if (( ping_refreshed )) && [[ -n "$ms" ]]; then
    latency_samples="${latency_samples:+${latency_samples}:}${ms}"
elif [[ -z "$latency_samples" && -n "$ms" ]]; then
    # Seed the rolling window when migrating cached state without samples.
    latency_samples=$ms
fi

# Start or clear the offline grace period. This also migrates state files that
# predate offline_since without briefly flashing the warning capsule.
if [[ -z "$ms" ]]; then
    (( offline_since == 0 )) && offline_since=$now
else
    offline_since=0
fi

# A confirmed outage invalidates samples from the previous connection.
if [[ -z "$ms" ]] && (( now - offline_since >= offline_grace )); then
    latency_samples=""
fi

# Keep the newest 30 samples and calculate the rolling mean.
latency_values=()
if [[ -n "$latency_samples" ]]; then
    IFS=: read -r -a latency_values <<< "$latency_samples"
fi
latency_count=${#latency_values[@]}
if (( latency_count > latency_max_samples )); then
    start=$(( latency_count - latency_max_samples ))
    latency_samples=""
    for (( i = start; i < latency_count; i++ )); do
        latency_samples="${latency_samples:+${latency_samples}:}${latency_values[i]}"
    done
    IFS=: read -r -a latency_values <<< "$latency_samples"
    latency_count=${#latency_values[@]}
fi

latency_sum=0
for value in "${latency_values[@]}"; do
    (( latency_sum += value ))
done

latency_mean=""
latency_ready=0
if (( latency_count > 0 )); then
    latency_mean=$(( (latency_sum + latency_count / 2) / latency_count ))
fi
if (( latency_count >= latency_min_samples )); then
    latency_ready=1
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

# Persist state
state_tmp="$state_file.$$.tmp"
printf 'ping_time=%s\nms=%s\nlatency_samples=%s\noffline_since=%s\nwired=%s\niface=%s\nrssi=%s\nprev_time=%s\nprev_rx=%s\nprev_tx=%s\nprev_rx_rate=%s\nprev_tx_rate=%s\n' \
    "$ping_time" "$ms" "$latency_samples" "$offline_since" "$wired" "$iface" "$rssi" "$prev_time" "$prev_rx" "$prev_tx" "$prev_rx_rate" "$prev_tx_rate" > "$state_tmp" \
    && mv -f "$state_tmp" "$state_file"

# Pick icon: wired or one of five RSSI-based Wi-Fi strength levels.
if [[ -n "$wired" ]]; then
    icon="󰈀"
elif [[ -z "$rssi" || "$rssi" -ge -55 ]]; then
    icon="󰤨"
elif (( rssi >= -67 )); then
    icon="󰤥"
elif (( rssi >= -75 )); then
    icon="󰤢"
elif (( rssi >= -85 )); then
    icon="󰤟"
else
    icon="󰤯"
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

warn=""
if [[ -z "$ms" ]]; then
    (( now - offline_since >= offline_grace )) && warn=1
elif (( latency_ready && latency_mean > 150 )); then
    warn=1
fi

if [[ -n "$warn" ]]; then
    # Warning mode keeps all text uniform for contrast on the amber background.
    traffic_str="⇃↾"
    if [[ -z "$ms" ]]; then
        text="󰤭 -- ${traffic_str}"
    elif (( !latency_ready )); then
        text="${icon} -- ${traffic_str}"
    else
        text="${icon} ${latency_mean}ms ${traffic_str}"
    fi
    result="#[fg=${c_warn_bg}]#[bg=${c_warn_bg}]${c_warn_fg} ${text} #[fg=${c_warn_bg}]#[bg=default] "
else
    # Normal mode: arrows are always present and colored only during activity.
    (( rx_active )) && rx_indicator="${c_rx}⇃" || rx_indicator="${c_base}⇃"
    (( tx_active )) && tx_indicator="${c_tx}↾" || tx_indicator="${c_base}↾"
    traffic_str="#[bold]${rx_indicator}${tx_indicator}#[nobold]"
    display_icon=$icon
    if (( !latency_ready && now % 2 )); then
        display_icon=" "
    fi
    if [[ -z "$ms" ]]; then
        text="${c_base}󰤭 -- ${traffic_str}"
    elif (( !latency_ready )); then
        text="${c_base}${display_icon} ${latency_mean}ms ${traffic_str}"
    else
        text="${c_base}${icon} ${latency_mean}ms ${traffic_str}"
    fi
    result="#[fg=${c_bg}]#[bg=${c_bg}] ${text} #[fg=${c_bg}]#[bg=default] "
fi

echo "$result"
