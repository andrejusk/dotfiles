#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install homebrew.
#

# macOS only
[[ "$DOTS_OS" != "macos" ]] && { log_skip "Not macOS"; return 0; }

if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Homebrew is already installed."
fi
brew --version | log_quote
log_pass "Homebrew installed"
