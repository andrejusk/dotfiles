#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Print system information with optional telemetry details.
#

trim() {
	local value="${1:-}"
	value="${value#${value%%[![:space:]]*}}"
	value="${value%${value##*[![:space:]]}}"
	printf '%s' "$value"
}

print_fetch() {
	if command -v fastfetch >/dev/null 2>&1; then
		fastfetch
		return
	fi

	if command -v neofetch >/dev/null 2>&1; then
		neofetch
		return
	fi

	log_warn "Skipping fetch output: fastfetch/neofetch not installed"
}

log_gpu_stats() {
	if ! command -v nvidia-smi >/dev/null 2>&1; then
		return
	fi

	local line
	line=$(nvidia-smi --query-gpu=name,driver_version,memory.used,memory.total,clocks.gr,clocks.mem --format=csv,noheader,nounits 2>/dev/null | head -n 1)
	if [[ -z "$line" ]]; then
		return
	fi

	IFS=',' read -r gpu_name driver mem_used mem_total clock_gr clock_mem <<< "$line"
	gpu_name=$(trim "$gpu_name")
	driver=$(trim "$driver")
	mem_used=$(trim "$mem_used")
	mem_total=$(trim "$mem_total")
	clock_gr=$(trim "$clock_gr")
	clock_mem=$(trim "$clock_mem")

	[[ -n "$gpu_name" ]] && log_info "GPU: ${gpu_name} (driver ${driver})"
	if [[ -n "$clock_gr" || -n "$clock_mem" ]]; then
		log_info "GPU clocks: ${clock_gr:-?} MHz graphics | ${clock_mem:-?} MHz memory"
	fi
	if [[ -n "$mem_used" && -n "$mem_total" ]]; then
		log_info "GPU memory usage: ${mem_used}/${mem_total} MiB"
	fi
}

log_cpu_stats() {
	if ! command -v lscpu >/dev/null 2>&1; then
		return
	fi

	local cpu_model cpu_cur cpu_max
	cpu_model=$(lscpu | awk -F: '/Model name/ {gsub(/^[ \t]+/, "", $2); print $2; exit}')
	cpu_cur=$(lscpu | awk -F: '/CPU MHz/ {gsub(/^[ \t]+/, "", $2); print $2; exit}')
	cpu_max=$(lscpu | awk -F: '/CPU max MHz/ {gsub(/^[ \t]+/, "", $2); print $2; exit}')

	[[ -n "$cpu_model" ]] && log_info "CPU: ${cpu_model}"
	if [[ -n "$cpu_cur" || -n "$cpu_max" ]]; then
		if [[ -n "$cpu_cur" && -n "$cpu_max" ]]; then
			log_info "CPU clock: current ${cpu_cur} MHz (max ${cpu_max} MHz)"
		elif [[ -n "$cpu_cur" ]]; then
			log_info "CPU clock: current ${cpu_cur} MHz"
		else
			log_info "CPU clock: max ${cpu_max} MHz"
		fi
	fi
}

print_fetch
log_gpu_stats
log_cpu_stats

unset -f trim
unset -f print_fetch
unset -f log_gpu_stats
unset -f log_cpu_stats
