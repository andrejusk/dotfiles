#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install the Zed editor.
#
#   Powers the `dev-container <repo> --zed` workflow (Zed GUI over SSH into the
#   in-VM devcontainer workspace, keeping files in the podman volume so the
#   Microsoft Defender open() scan is bypassed) and Zed's Agent Panel /
#   Inline Assistant driven by the local MLX model via `dev-model`.
#
#   Config is stowed to ~/.config/zed/settings.json (local MLX provider +
#   podman devcontainer settings). Add opencode as an external agent in Zed via
#   the ACP registry: run `zed: acp registry` and install OpenCode.
#

# macOS only
[[ "$DOTS_OS" != "macos" ]] && { log_skip "Not macOS"; return 0; }

if ! echo "$BREW_CASKS" | grep -q "^zed$"; then
    # --adopt takes over an existing manual /Applications/Zed.app instead of erroring.
    brew install --cask --adopt zed
fi
log_pass "Zed installed"
echo "$BREW_CASK_VERSIONS" | grep "^zed " | log_quote || true
