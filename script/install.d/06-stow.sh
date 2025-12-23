#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install and run stow.
#

if ! command -v stow &> /dev/null; then
    case "$DOTS_PKG" in
        apt)
            sudo apt-get install -qq stow
            ;;
        pacman)
            sudo pacman -S --noconfirm stow
            ;;
        brew)
            brew install stow
            ;;
        *)
            log_warn "Skipping stow install: no supported package manager found"
            return 0
            ;;
    esac
fi

stow --version

root_dir=${DOTFILES:-$(dirname "$(dirname "$(dirname "$(realpath "$0")")")")}

rm -f "$HOME/.bash_profile"
rm -f "$HOME/.bashrc"
rm -f "$HOME/.gitconfig"
rm -f "$HOME/.profile"
rm -f "$HOME/.zshrc"
rm -f "$HOME/.p10k.zsh"
rm -f "$HOME/.ssh/config"

mkdir -p "$HOME/.config"
mkdir -p "$HOME/.ssh"

stow --dir="$root_dir/files" --target="$HOME" home
stow --dir="$root_dir/files" --target="$HOME/.config" dot-config
stow --dir="$root_dir/files" --target="$HOME/.ssh" dot-ssh
