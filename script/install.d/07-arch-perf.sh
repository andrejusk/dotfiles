#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Apply Arch/CachyOS performance tuning when NVIDIA hardware is present.
#

enable_unit_if_available() {
    local unit=$1
    if systemctl list-unit-files --no-legend 2>/dev/null | awk '{print $1}' | grep -Fxq "$unit"; then
        if sudo systemctl enable --now "$unit" >/dev/null 2>&1; then
            log_info "Enabled systemd unit: $unit"
        else
            log_warn "Unable to enable $unit"
        fi
    else
        log_warn "Unit $unit not found; skipping"
    fi
}

skip_with_reason() {
    log_warn "$1"
    return 0
}

main() {
    if [[ "${OSTYPE:-}" != linux-gnu* ]]; then
        skip_with_reason "Skipping Arch performance tuning: requires Linux"
        return
    fi

    if [[ ! -r /etc/os-release ]]; then
        skip_with_reason "Skipping Arch performance tuning: /etc/os-release not found"
        return
    fi

    # shellcheck disable=SC1091
    . /etc/os-release

    local id_lower id_like_lower
    id_lower=$(echo "${ID:-}" | tr '[:upper:]' '[:lower:]')
    id_like_lower=$(echo "${ID_LIKE:-}" | tr '[:upper:]' '[:lower:]')

    if [[ "$id_lower" != "arch" && "$id_lower" != "cachyos" && "$id_like_lower" != *"arch"* ]]; then
        skip_with_reason "Skipping Arch performance tuning: ${NAME:-unknown} is not Arch based"
        return
    fi

    if ! command -v pacman >/dev/null 2>&1; then
        skip_with_reason "Skipping Arch performance tuning: pacman not available"
        return
    fi

    if ! command -v nvidia-smi >/dev/null 2>&1; then
        skip_with_reason "Skipping Arch performance tuning: NVIDIA utilities not detected"
        return
    fi

    log_info "Applying performance profile for ${NAME:-Arch Linux}"

    local -a packages=(
        cpupower
        fastfetch
        gamemode
        lib32-gamemode
        lib32-nvidia-utils
        nvidia-settings
        nvidia-utils
        nvtop
        vulkan-tools
    )

    log_info "Ensuring required packages are installed"
    sudo pacman -S --noconfirm --needed "${packages[@]}"

    log_info "Configuring cpupower defaults"
    sudo tee /etc/default/cpupower >/dev/null <<'EOF'
# Managed by dotfiles performance install
governor='schedutil'
min_freq='0'
max_freq='0'
EOF
    enable_unit_if_available "cpupower.service"

    log_info "Writing sysctl overrides"
    sudo tee /etc/sysctl.d/99-dots-performance.conf >/dev/null <<'EOF'
# Managed by dotfiles performance install
vm.swappiness = 10
vm.vfs_cache_pressure = 50
kernel.unprivileged_userns_clone = 1
EOF
    sudo sysctl -p /etc/sysctl.d/99-dots-performance.conf >/dev/null

    log_info "Setting transparent huge page policy"
    sudo tee /etc/tmpfiles.d/dots-performance-thp.conf >/dev/null <<'EOF'
# Managed by dotfiles performance install
w /sys/kernel/mm/transparent_hugepage/enabled - - - - madvise
w /sys/kernel/mm/transparent_hugepage/defrag - - - - madvise
EOF
    sudo systemd-tmpfiles --create /etc/tmpfiles.d/dots-performance-thp.conf

    log_info "Configuring NVMe scheduler"
    sudo tee /etc/udev/rules.d/60-dots-nvme-scheduler.rules >/dev/null <<'EOF'
# Managed by dotfiles performance install
ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"
EOF
    sudo udevadm control --reload-rules
    sudo udevadm trigger --subsystem-match=block --action=change

    log_info "Applying NVIDIA module defaults"
    sudo tee /etc/modprobe.d/dots-nvidia-performance.conf >/dev/null <<'EOF'
# Managed by dotfiles performance install
options nvidia NVreg_UsePageAttributeTable=1
options nvidia NVreg_InitializeSystemMemoryAllocations=0
options nvidia NVreg_EnableGpuFirmware=1
options nvidia_drm modeset=1 fbdev=1
EOF

    if command -v mkinitcpio >/dev/null 2>&1; then
        log_info "Rebuilding initramfs for NVIDIA modules"
        sudo mkinitcpio -P >/dev/null
    fi

    enable_unit_if_available "nvidia-persistenced.service"
    enable_unit_if_available "fstrim.timer"

    local config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
    mkdir -p "$config_home"

    log_info "Writing GameMode configuration"
    cat <<'EOF' > "$config_home/gamemode.ini"
# Managed by dotfiles performance install
[general]
renice=10
ioprio=0
inhibit_screensaver=1

[cpu]
desiredgov=schedutil

[gpu]
apply_gpu_optimisations=accept
gpu_device=0
nv_powermizer_mode=1

[custom]
start=logger -t dots-perf "GameMode activated"
end=logger -t dots-perf "GameMode deactivated"
EOF

    log_info "Configuring Proton/DXVK defaults"
    local env_dir="$config_home/environment.d"
    mkdir -p "$env_dir"
    cat <<'EOF' > "$env_dir/99-dots-performance.conf"
# Managed by dotfiles performance install
PROTON_ENABLE_NVAPI=1
PROTON_HIDE_NVIDIA_GPU=0
DXVK_ASYNC=1
__GL_THREADED_OPTIMIZATION=1
EOF

    log_pass "Arch performance tuning complete"
}

main "$@"
unset -f main
unset -f enable_unit_if_available
unset -f skip_with_reason
