#!/bin/bash
#
# After running this script:
#   1. python is installed
#

# 1. python is installed
if ! hash python 2>/dev/null; then

    printf "Installing python...\n"

    pyenv install -s 3.7.0
    pyenv global 3.7.0

fi
printf "python is installed\n"
