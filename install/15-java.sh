#!/usr/bin/env bash
source "$(dirname $0)/utils.sh"

if not_installed "java"; then
    echo "Installing java..."
    install default-jre
fi

echo "java is installed"
java --version
