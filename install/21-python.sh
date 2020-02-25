#!/bin/bash
#
# After running this script:
#   1. python is installed
#

# 1. python is installed
if not_installed "python"; then

    printf "Installing python...\n"

    pyenv install -s 3.7.0
    pyenv global 3.7.0

fi
printf "python is installed\n"
