#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install and configure tmux.
#

if ! command -v tmux &> /dev/null; then
    case "$DOTS_PKG" in
        apt)
            sudo apt-get install -qq tmux
            ;;
        pacman)
            sudo pacman -S --noconfirm tmux
            ;;
        brew)
            brew install tmux
            ;;
        *)
            log_warn "Skipping tmux install: no supported package manager found"
            return 0
            ;;
    esac
fi

# Compile screensaver (skip if binary is newer than source)
if command -v cc &> /dev/null && [ -f "$HOME/.tmux/donut.c" ]; then
    if [ ! -f "$HOME/.tmux/donut" ] || [ "$HOME/.tmux/donut.c" -nt "$HOME/.tmux/donut" ]; then
        cc -O2 -o "$HOME/.tmux/donut" "$HOME/.tmux/donut.c" -lm
    fi
fi

log_pass "tmux configured"
tmux -V | log_quote

# Install tmux plugins (TPM + session persistence). Cloned directly so they
# load headlessly, i.e. without an interactive `prefix + I`. ~/.tmux/plugins is
# a stow-folded symlink into the repo, so this dir is gitignored.
if command -v git &> /dev/null; then
    tmux_plugin_dir="$HOME/.tmux/plugins"
    mkdir -p "$tmux_plugin_dir"

    tmux_plugins=(
        "https://github.com/tmux-plugins/tpm.git"
        "https://github.com/tmux-plugins/tmux-resurrect.git"
        "https://github.com/tmux-plugins/tmux-continuum.git"
    )

    for url in "${tmux_plugins[@]}"; do
        name=$(basename "$url" .git)
        dest="$tmux_plugin_dir/$name"
        if [[ -d "$dest" ]]; then
            git -C "$dest" pull --quiet &
        else
            git clone --depth 1 --quiet "$url" "$dest" &
        fi
    done
    wait

    log_pass "tmux plugins configured"
    for url in "${tmux_plugins[@]}"; do
        name=$(basename "$url" .git)
        echo "$name" | log_quote
    done

    # NOTE: Do NOT seed an empty resurrect "last" file. An empty-but-existing
    # save makes tmux-resurrect's restore (triggered by @continuum-restore 'on')
    # treat the single-pane startup as "restore from scratch", restore nothing,
    # then kill session 0 — taking the whole server down on every start. When the
    # file is absent, restore aborts cleanly (the harmless "Tmux resurrect file
    # not found!" status flashes until continuum's first auto-save). Remove any
    # stale empty seed left by older versions of this script.
    resurrect_dir="${XDG_DATA_HOME:-$HOME/.local/share}/tmux/resurrect"
    if [[ -f "$resurrect_dir/last" && ! -s "$resurrect_dir/last" ]]; then
        rm -f "$resurrect_dir/last"
    fi
else
    log_warn "Skipping tmux plugins: git not found"
fi

