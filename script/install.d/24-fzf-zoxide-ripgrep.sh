#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install fzf, zoxide, and ripgrep for enhanced shell workflow.
#

# Install fzf (fuzzy finder)
if ! command -v fzf &>/dev/null; then
    log_info "Installing fzf..."
    case "$DOTS_PKG" in
        apt)
            sudo apt-get install -qq fzf &>/dev/null
            ;;
        pacman)
            sudo pacman -S --noconfirm fzf &>/dev/null
            ;;
        brew)
            brew install fzf
            ;;
        dnf)
            sudo dnf install -y fzf &>/dev/null
            ;;
        *)
            log_warn "Skipping fzf install: no supported package manager found"
            ;;
    esac
fi

if command -v fzf &>/dev/null; then
    log_pass "fzf: $(fzf --version 2>&1 | head -1)"
else
    log_warn "fzf not installed"
fi

# Install zoxide (smarter cd)
if ! command -v zoxide &>/dev/null; then
    log_info "Installing zoxide..."
    case "$DOTS_PKG" in
        apt)
            # For Debian/Ubuntu, use the curl installer as package may be outdated
            curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
            ;;
        pacman)
            sudo pacman -S --noconfirm zoxide &>/dev/null
            ;;
        brew)
            brew install zoxide
            ;;
        dnf)
            sudo dnf install -y zoxide &>/dev/null
            ;;
        *)
            log_warn "Skipping zoxide install: no supported package manager found"
            ;;
    esac
fi

if command -v zoxide &>/dev/null; then
    log_pass "zoxide: $(zoxide --version 2>&1)"
else
    log_warn "zoxide not installed"
fi

# Install ripgrep (fast grep)
if ! command -v rg &>/dev/null; then
    log_info "Installing ripgrep..."
    case "$DOTS_PKG" in
        apt)
            sudo apt-get install -qq ripgrep &>/dev/null
            ;;
        pacman)
            sudo pacman -S --noconfirm ripgrep &>/dev/null
            ;;
        brew)
            brew install ripgrep
            ;;
        dnf)
            sudo dnf install -y ripgrep &>/dev/null
            ;;
        *)
            log_warn "Skipping ripgrep install: no supported package manager found"
            ;;
    esac
fi

if command -v rg &>/dev/null; then
    log_pass "ripgrep: $(rg --version 2>&1 | head -1)"
else
    log_warn "ripgrep not installed"
fi
