#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Print operating system information and hint which installer path will run.
#

log_info "Environment: DOTS_OS=$DOTS_OS, DOTS_PKG=$DOTS_PKG, DOTS_ENV=$DOTS_ENV"

if [[ "$DOTS_OS" == "macos" ]]; then
    # macOS info
    sw_vers
    log_info "Detected macOS (OSTYPE=$OSTYPE)"
    log_info "Package manager: Homebrew (brew)"
    log_info "Code path: macOS-only brew scripts will run; Linux package scripts are skipped."

elif [[ "$DOTS_OS" == "linux" ]]; then
    # Linux info
    if [[ -r /etc/os-release ]]; then
        cat /etc/os-release
        # shellcheck source=/dev/null
        . /etc/os-release
    fi

    log_info "Detected Linux (OSTYPE=$OSTYPE, ID=${ID:-unknown}, ID_LIKE=${ID_LIKE:-n/a}, NAME=${NAME:-n/a}, VERSION_ID=${VERSION_ID:-n/a})"
    log_info "Package manager detected: ${DOTS_PKG:-none}"

    if [[ -z "$DOTS_PKG" ]]; then
        log_warn "No known package manager (apt-get/pacman/dnf) found on Linux."
    fi

else
    log_error "Unknown OS: $OSTYPE"
fi

if [[ "$DOTS_ENV" == "codespaces" ]]; then
    log_info "Running in GitHub Codespaces"
fi
