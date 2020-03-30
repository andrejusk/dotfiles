#!/usr/bin/env bash

if not_installed "java"; then
    echo "Installing java..."
    install default-jre
fi

echo "java is installed"
java --version
