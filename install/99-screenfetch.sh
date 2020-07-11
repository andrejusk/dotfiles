#!/usr/bin/env bash
source "$(dirname $0)/utils.sh"

if not_installed "screenfetch"; then
    echo "Installing screenfetch..."
    install screenfetch
fi

echo "screenfetch is installed"
screenfetch --version
screenfetch
