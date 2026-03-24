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

root_dir=${DOTFILES:-$(dirname "$(dirname "$(dirname "$(realpath "$0")")")")}

rm -f "$HOME/.bash_profile"
rm -f "$HOME/.bashrc"
rm -f "$HOME/.gitconfig"
rm -f "$HOME/.gitconfig.local"
rm -f "$HOME/.profile"
rm -f "$HOME/.zshrc"
rm -f "$HOME/.p10k.zsh"
rm -f "$HOME/.ssh/config"

mkdir -p "$HOME/.config"
mkdir -p "$HOME/.ssh"

stow --dir="$root_dir" --target="$HOME" home

# In Codespaces, remove .gitconfig.local so the auto-provisioned identity is used
if [[ "$DOTS_ENV" == "codespaces" ]]; then
    rm -f "$HOME/.gitconfig.local"
fi

# Bust PATH cache to force rebuild with new profile
rm -f "${XDG_CACHE_HOME:-$HOME/.cache}/dots/path"

# Compile zsh dotfiles for faster shell startup
if command -v zsh &>/dev/null; then
    zsh -c '
        for f in ~/.zsh/*.zsh ~/.aliases ~/.profile(N); do
            [[ $f.zwc -nt $f ]] || zcompile "$f" 2>/dev/null
        done
    '
fi

# Bust tool init caches so they regenerate with new PATH/tools
rm -f "${XDG_CACHE_HOME:-$HOME/.cache}"/dots/{fzf,mise,zoxide}.zsh{,.zwc}

log_pass "stow linked"
stow --version | log_quote

