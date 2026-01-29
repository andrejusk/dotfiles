#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Print operating system information and hint which installer path will run.
#

log_info "Environment: DOTS_OS=$DOTS_OS, DOTS_PKG=$DOTS_PKG, DOTS_ENV=$DOTS_ENV"

if [[ "$DOTS_OS" == "macos" ]]; then
    sw_vers
elif [[ "$DOTS_OS" == "linux" ]]; then
    if [[ -r /etc/os-release ]]; then
        cat /etc/os-release
    fi
    
    if [[ -z "$DOTS_PKG" ]]; then
        log_warn "No known package manager found on Linux"
    fi
else
    log_error "Unknown OS: $DOTS_OS"
fi

if [[ "$DOTS_ENV" == "codespaces" ]]; then
    log_info "Running in GitHub Codespaces"
fi
