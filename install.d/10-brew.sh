#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install homebrew.
#

# macOS only
[[ "$DOTS_OS" != "macos" ]] && { log_skip "Not macOS"; return 0; }

if ! command -v brew &> /dev/null; then
    log_info "Installing Homebrew..."
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    log_skip "Homebrew already installed"
fi
log_pass "Homebrew installed"
echo "Homebrew $(cat "$(brew --repository 2>/dev/null)"/.git/describe-cache/* 2>/dev/null || brew --version | head -1)" | log_quote
