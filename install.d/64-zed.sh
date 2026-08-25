#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS only) Install the Zed editor.
#
#   Zed's Agent Panel / Inline Assistant is driven by the local MLX model via
#   `dev-model`.
#
#   Config is stowed to ~/.config/zed/settings.json. Add opencode as an external
#   agent in Zed via the ACP registry: run `zed: acp registry` and install
#   OpenCode.
#

# macOS only
[[ "$DOTS_OS" != "macos" ]] && { log_skip "Not macOS"; return 0; }

if ! echo "$BREW_CASKS" | grep -q "^zed$"; then
    # --adopt takes over an existing manual /Applications/Zed.app instead of erroring.
    brew install --cask --adopt zed
fi
log_pass "Zed installed"
echo "$BREW_CASK_VERSIONS" | grep "^zed " | log_quote || true
