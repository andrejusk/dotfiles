#!/usr/bin/env bash
# Battery indicator for tmux status bar.
# Shows a 30s p90 power estimate from macmon, including battery charging power.
# Charging: percentage + adapter output estimate. Full: system power only.
# Discharging: percentage + system power. Amber warning capsule when <=20%.
# If no battery is present (e.g. desktop tower, VM), exits with 0 and emits nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
state_dir="${XDG_RUNTIME_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/tmux}"
state_file="$state_dir/power"
now=$(date +%s)

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

# Refresh power telemetry every 2s and retain a 30s rolling window.
power_time=0
power_mode=""
power_samples=""
power_dw=""
if [[ -r "$state_file" ]]; then
    while IFS='=' read -r key value; do
        case "$key" in
            power_time)
                [[ "$value" =~ ^[0-9]{1,10}$ ]] && power_time=$value ;;
            power_mode)
                [[ "$value" == "charging" || "$value" == "full" || "$value" == "battery" ]] \
                    && power_mode=$value ;;
            power_samples)
                [[ -z "$value" || "$value" =~ ^[0-9]{1,7}(:[0-9]{1,7}){0,14}$ ]] \
                    && power_samples=$value ;;
            power_dw)
                [[ -z "$value" || "$value" =~ ^[0-9]{1,7}$ ]] && power_dw=$value ;;
        esac
    done < "$state_file"
fi

if [[ -n "$full" ]]; then
    current_mode="full"
elif [[ -n "$charging" ]]; then
    current_mode="charging"
else
    current_mode="battery"
fi

if [[ "$power_mode" != "$current_mode" ]]; then
    power_time=0
    power_samples=""
    power_dw=""
    power_mode=$current_mode
fi

if [[ "$(uname)" == "Darwin" ]] && (( now - power_time >= 2 || power_time == 0 )); then
    metrics=$(curl -fsS --max-time 1 http://127.0.0.1:9090/metrics 2>/dev/null)
    system_dw=$(printf '%s\n' "$metrics" | awk '
        $1 ~ /^macmon_all_power_watts/ { all = $NF; have_all = 1 }
        $1 ~ /^macmon_sys_power_watts/ { sys_value = $NF; have_system = 1 }
        END {
            if (have_system && sys_value > 0) value = sys_value
            else if (have_all) value = all
            else exit
            printf "%.0f", value * 10
        }
    ')

    if [[ "$system_dw" =~ ^[0-9]{1,7}$ ]]; then
        sample_dw=$system_dw
        if [[ "$current_mode" == "charging" ]]; then
            read -r voltage_mv current_ma < <(
                ioreg -r -c AppleSmartBattery -l 2>/dev/null | awk '
                    /"Voltage" =/ && voltage == "" { voltage = $NF }
                    /"InstantAmperage" =/ && current == "" { current = $NF }
                    voltage != "" && current != "" { print voltage, current; exit }
                '
            )
            if [[ "$voltage_mv" =~ ^[0-9]{1,6}$ && "$current_ma" =~ ^[0-9]{1,6}$ ]] \
                && (( current_ma > 0 )); then
                sample_dw=$(( sample_dw + (voltage_mv * current_ma + 50000) / 100000 ))
            fi
        fi

        power_samples="${power_samples:+${power_samples}:}${sample_dw}"
        IFS=: read -r -a values <<< "$power_samples"
        count=${#values[@]}
        if (( count > 15 )); then
            start=$(( count - 15 ))
            power_samples=""
            for (( i = start; i < count; i++ )); do
                power_samples="${power_samples:+${power_samples}:}${values[i]}"
            done
        fi
        IFS=: read -r -a values <<< "$power_samples"
        count=${#values[@]}
        sorted=$(printf '%s\n' "${values[@]}" | sort -n)
        rank=$(( (count * 9 + 9) / 10 ))
        power_dw=$(printf '%s\n' "$sorted" | sed -n "${rank}p")
        power_time=$now
    fi
fi

mkdir -p "$state_dir" 2>/dev/null
state_tmp="$state_file.$$.tmp"
printf 'power_time=%s\npower_mode=%s\npower_samples=%s\npower_dw=%s\n' \
    "$power_time" "$power_mode" "$power_samples" "$power_dw" > "$state_tmp" \
    && mv -f "$state_tmp" "$state_file"

format_power() {
    local dw=$1
    if (( dw % 10 == 0 )); then
        printf '%dW' "$(( dw / 10 ))"
    else
        printf '%d.%dW' "$(( dw / 10 ))" "$(( dw % 10 ))"
    fi
}

power=""
if [[ -n "$power_dw" ]] && (( now - power_time <= 10 )); then
    power=$(format_power "$power_dw")
fi

warn=""
if [[ -n "$full" ]]; then
    text="󰚥 ${power:-AC}"
elif [[ -n "$charging" ]]; then
    text="󰂄 ${pct}%${power:+ ${power}}"
elif (( pct <= 10 )); then
    text="󰂎 ${pct}%${power:+ ${power}}"
    warn=1
elif (( pct <= 20 )); then
    text="󰁺 ${pct}%${power:+ ${power}}"
    warn=1
elif (( pct <= 40 )); then
    text="󰁼 ${pct}%${power:+ ${power}}"
elif (( pct <= 60 )); then
    text="󰁾 ${pct}%${power:+ ${power}}"
elif (( pct <= 80 )); then
    text="󰂀 ${pct}%${power:+ ${power}}"
else
    text="󰁹 ${pct}%${power:+ ${power}}"
fi

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
