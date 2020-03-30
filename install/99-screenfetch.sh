#!/usr/bin/env bash

if not_installed "screenfetch"; then
    echo "Installing screenfetch..."
    install screenfetch
fi

echo "screenfetch is installed"
screenfetch --version
screenfetch
