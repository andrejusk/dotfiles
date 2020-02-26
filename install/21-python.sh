#!/usr/bin/env bash
#
# After running this script:
#   1. python3 is installed
#

# 1. python is installed
if not_installed "python3"; then

    printf "Installing python3...\n"

    pyenv install -s 3.7.0
    pyenv global 3.7.0

fi
printf "python3 is installed\n"
