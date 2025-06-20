#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Clean up after installation.
#

if [[ "$OSTYPE" == "darwin"* ]]; then
    brew cleanup
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt-get autoremove -qq
    sudo apt-get clean -qq
fi

log_pass "Cleanup completed successfully!"
