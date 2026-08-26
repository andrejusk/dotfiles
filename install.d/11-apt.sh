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

# Codespaces images provide the installer prerequisites. Avoid even querying
# dpkg here: on freshly created Codespaces its package database can take several
# seconds to scan, while missing tools will fail explicitly at their use site.
if [[ "$DOTS_ENV" == "codespaces" ]]; then
    log_skip "Core apt packages provided by Codespaces"
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
