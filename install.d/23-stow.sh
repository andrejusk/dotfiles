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
rm -f "$HOME/.gitconfig.work"
rm -f "$HOME/.profile"
rm -f "$HOME/.zshrc"
rm -f "$HOME/.p10k.zsh"
rm -f "$HOME/.ssh/config"

mkdir -p "$HOME/.config"
mkdir -p "$HOME/.ssh"
# Ensure ~/.local (and its bin dir) exist as real dirs so stow links only the
# tracked bin/ scripts, rather than folding the whole tree into the repo. On a
# fresh machine ~/.local doesn't exist, so stow would otherwise create
# ~/.local -> repo/home/.local and mise/gh/zsh would then write GBs of runtime
# state (~/.local/share, ~/.local/state) straight into the working tree.
mkdir -p "$HOME/.local/bin"
# Ensure ~/.config/Code exists as a real dir so stow links only the tracked
# settings.json; otherwise a fresh Linux box would fold ~/.config/Code into the
# repo and VSCode would write its state (globalStorage, etc.) into the tree.
mkdir -p "$HOME/.config/Code/User"
# Ensure ~/.config/zed is a real dir so stow links only settings.json, not the
# whole dir (Zed also writes keymap.json / other state there).
mkdir -p "$HOME/.config/zed"
# Ensure ~/.config/opencode is a real dir so stow links only opencode.json;
# auth/session state belongs in ~/.local/share/opencode, not the repo.
mkdir -p "$HOME/.config/opencode"
# Ensure ~/.copilot (and the hooks dir) exist as real dirs so stow links only
# the hooks file inside, rather than folding the whole state-heavy dir into the repo.
mkdir -p "$HOME/.copilot/hooks"
# Same for the skills tree: mkdir the leaf so stow links only SKILL.md, leaving
# ~/.copilot/skills writable for locally-added skills (`copilot skill add`).
mkdir -p "$HOME/.copilot/skills/local-dev-container"

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
