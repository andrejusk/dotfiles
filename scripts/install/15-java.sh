#!/usr/bin/env bash
if not_installed "java"; then
    install default-jre
fi

java --version
