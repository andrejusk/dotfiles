#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (distros with apt only) Install core apt packages.
#

# apt only
[[ "$DOTS_PKG" != "apt" ]] && { log_skip "Not using apt"; return 0; }

apt_packages=(
    build-essential
    ca-certificates
    curl
    gnupg
    gnupg2
    wget
)

# Codespaces images already contain these core packages and package indexes.
# Keep the baked indexes for later installs (notably Stow), refreshing only if
# an install reports that the metadata is stale or incomplete.
if [[ "$DOTS_ENV" == "codespaces" ]] && dpkg -s "${apt_packages[@]}" &>/dev/null; then
    log_skip "Core apt packages provided by Codespaces; using cached indexes"
    apt --version | log_quote
    unset apt_packages
    return 0
fi

sudo apt-get update -qq

# Skip install if all packages already installed
if dpkg -s "${apt_packages[@]}" &>/dev/null; then
    apt --version | log_quote
    return 0
fi

sudo apt-get install -qq "${apt_packages[@]}"

unset apt_packages

log_pass "apt packages installed"
apt --version | log_quote
