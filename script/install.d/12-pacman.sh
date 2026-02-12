#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (distros with pacman only) Install core pacman packages.
#

# pacman only
[[ "$DOTS_PKG" != "pacman" ]] && { log_warn "Skipping: Not using pacman"; return 0; }

pacman_packages=(
    ca-certificates
    curl
    git
    gnupg
    wget
    base-devel
)

sudo pacman -Sy --noconfirm
sudo pacman -S --noconfirm --needed "${pacman_packages[@]}"

unset pacman_packages

# Install yay (AUR helper)
if ! command -v yay &>/dev/null; then
    log_info "Installing yay..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    rm -rf /tmp/yay
fi

pacman --version
yay --version
