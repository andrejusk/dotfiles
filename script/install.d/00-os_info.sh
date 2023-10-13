#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Print operating system information.
#

if [[ "$OSTYPE" == "darwin"* ]]; then
    sw_vers
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    lsb_release -a
fi
