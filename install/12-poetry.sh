#!/usr/bin/env bash

# 1. poetry is installed
if not_installed "poetry"; then

    printf "Installing poetry...\n"

    # Install poetry
    pip3 install --user poetry

fi
printf "poetry is installed, upgrading...\n"
pip3 install --upgrade poetry
poetry --version
