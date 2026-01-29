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
    gnupg
    wget
    base-devel
)

sudo pacman -Sy --noconfirm
sudo pacman -S --noconfirm --needed "${pacman_packages[@]}"

unset pacman_packages

pacman --version
