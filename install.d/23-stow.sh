#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Link dotfiles with GNU Stow, or a lightweight equivalent in Codespaces.
#

if [[ "$DOTS_ENV" != "codespaces" ]] && ! command -v stow &> /dev/null; then
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

_dots_link_tree() {
    local source_dir=$1
    local target_dir=$2
    local source_path target_path
    local -a entries

    shopt -s dotglob nullglob
    entries=("$source_dir"/*)
    shopt -u dotglob nullglob

    for source_path in "${entries[@]}"; do
        case "${source_path##*/}" in
            .git|.gitignore|.gitmodules) continue ;;
        esac

        target_path="$target_dir/${source_path##*/}"

        if [[ -L "$target_path" ]]; then
            [[ "$(readlink "$target_path")" == "$source_path" ]] || \
                ln -sfn "$source_path" "$target_path"
        elif [[ ! -e "$target_path" ]]; then
            ln -s "$source_path" "$target_path"
        elif [[ -d "$source_path" && -d "$target_path" ]]; then
            _dots_link_tree "$source_path" "$target_path"
        else
            log_error "Cannot link $target_path: existing path is not managed by dotfiles"
            return 1
        fi
    done
}

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
# Ensure ~/.config/zed is a real dir so stow links only settings.json, not the
# whole dir (Zed also writes keymap.json / other state there).
mkdir -p "$HOME/.config/zed"
# Ensure ~/.config/opencode is a real dir so stow links only opencode.json;
# auth/session state belongs in ~/.local/share/opencode, not the repo.
mkdir -p "$HOME/.config/opencode"
# Ensure ~/.copilot (and the hooks dir) exist as real dirs so stow links only
# the hooks file inside, rather than folding the whole state-heavy dir into the repo.
mkdir -p "$HOME/.copilot/hooks"
if [[ "$DOTS_ENV" == "codespaces" ]]; then
    # Codespaces is ephemeral and installing Stow can spend over a minute in
    # apt/dpkg. This implements the subset used by the single `home` package:
    # fold absent directories into symlinks and descend into existing ones.
    _dots_link_tree "$root_dir/home" "$HOME"
else
    stow --dir="$root_dir" --target="$HOME" home
fi

# In Codespaces, remove .gitconfig.local so the auto-provisioned identity is used
if [[ "$DOTS_ENV" == "codespaces" ]]; then
    rm -f "$HOME/.gitconfig.local"
fi

# Bust PATH cache to force rebuild with new profile
rm -f "${XDG_CACHE_HOME:-$HOME/.cache}/dots/path"

# Compile zsh dotfiles for faster shell startup. Codespaces uses the tracked
# caches and lets Zsh ignore them if stale rather than writing into the clone.
if [[ "$DOTS_ENV" != "codespaces" ]] && command -v zsh &>/dev/null; then
    zsh -c '
        for f in ~/.zsh/*.zsh ~/.aliases ~/.profile(N); do
            [[ $f.zwc -nt $f ]] || zcompile "$f" 2>/dev/null
        done
    '
fi

# Bust tool init caches so they regenerate with new PATH/tools
rm -f "${XDG_CACHE_HOME:-$HOME/.cache}"/dots/{fzf,mise,zoxide}.zsh{,.zwc}

unset -f _dots_link_tree

if [[ "$DOTS_ENV" == "codespaces" ]]; then
    log_pass "dotfiles linked"
else
    log_pass "stow linked"
    stow --version | log_quote
fi
