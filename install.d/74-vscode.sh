#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install Visual Studio Code (Homebrew Cask managed).
#

# macOS only
[[ "$DOTS_OS" != "macos" ]] && { log_skip "Not macOS"; return 0; }

if echo "$BREW_CASKS" | grep -q "^visual-studio-code$"; then
    log_skip "VSCode already cask-managed"
else
    # --adopt takes ownership of an existing /Applications/Visual Studio Code.app
    # (e.g. a one-off manual install) instead of erroring on the collision, so
    # brew manages upgrades from here on. Requires Homebrew >= 4.3.0.
    brew install --cask --adopt visual-studio-code
fi
log_pass "VSCode installed"
echo "$BREW_CASK_VERSIONS" | grep "^visual-studio-code " | log_quote || true

# Adopt the dotfiles-tracked settings.json. VSCode on macOS reads from the
# Library path, so symlink it to the repo copy (the canonical file lives at the
# Linux-native ~/.config/Code/User path, which stow links directly on Linux).
# NOTE: turn OFF Settings Sync for the "Settings" resource, otherwise Sync keeps
# overwriting this file (Command Palette > "Settings Sync: Configure..." >
# uncheck Settings).
vscode_user_dir="$HOME/Library/Application Support/Code/User"
vscode_settings_src="${DOTFILES:-$HOME/.dotfiles}/home/.config/Code/User/settings.json"
mkdir -p "$vscode_user_dir"
if [[ -e "$vscode_user_dir/settings.json" && ! -L "$vscode_user_dir/settings.json" ]]; then
    mv "$vscode_user_dir/settings.json" "$vscode_user_dir/settings.json.pre-dotfiles.bak"
    log_info "Backed up existing VSCode settings to settings.json.pre-dotfiles.bak"
fi
ln -sfn "$vscode_settings_src" "$vscode_user_dir/settings.json"
log_pass "VSCode settings symlinked"
