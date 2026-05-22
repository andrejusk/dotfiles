#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (distros with apk only) Install core apk packages.
#   Covers Alpine Linux and iSH (iOS).
#

# apk only
[[ "$DOTS_PKG" != "apk" ]] && { log_skip "Not using apk"; return 0; }

apk_packages=(
    build-base
    ca-certificates
    coreutils
    curl
    git
    gnupg
    openssh
    wget
)

sudo apk update --quiet
sudo apk add --quiet "${apk_packages[@]}"

unset apk_packages

log_pass "apk packages installed"
apk --version | log_quote
