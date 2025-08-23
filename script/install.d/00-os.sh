#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Print operating system information and hint which installer path will run.
#

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS info
    sw_vers
    log_info "Detected macOS (OSTYPE=$OSTYPE)"
    log_info "Package manager: Homebrew (brew)"
    log_info "Code path: macOS-only brew scripts will run; Linux package scripts are skipped."

elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux info
    if [[ -r /etc/os-release ]]; then
        cat /etc/os-release
        # shellcheck source=/dev/null
        . /etc/os-release
    fi

    log_info "Detected Linux (OSTYPE=$OSTYPE, ID=${ID:-unknown}, ID_LIKE=${ID_LIKE:-n/a}, NAME=${NAME:-n/a}, VERSION_ID=${VERSION_ID:-n/a})"

    if command -v apt-get >/dev/null 2>&1; then
        log_info "Package manager detected: apt-get"
        export DOTS_PKG_MGR=apt
    elif command -v pacman >/dev/null 2>&1; then
        log_info "Package manager detected: pacman"
        export DOTS_PKG_MGR=pacman
    else
        log_warn "No known package manager (apt-get/pacman) found on Linux."
    fi

else
    log_error "Unknown OS: $OSTYPE"
fi
