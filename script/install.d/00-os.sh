#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Print operating system information.
#

if [[ "$OSTYPE" == "darwin"* ]]; then
    sw_vers
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    cat /etc/os-release
else
    log_error "Unknown OS: $OSTYPE"
fi
