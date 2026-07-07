#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (macOS / Apple Silicon) Install the local dev-container toolchain: podman +
#   the Dev Containers CLI. These power the `dev-container` helper, which runs a
#   repo's devcontainer in a Linux VM with the working tree in a named VOLUME,
#   so file I/O escapes Microsoft Defender's per-file open() scan (~90x faster
#   search/build/test on huge repos — see home/.local/bin/dev-container).
#
#   Binaries only: the podman machine (VM) is initialised lazily on first
#   `dev-container` run, keeping this step fast and network-fault tolerant.
#   Not gated on DOTS_DEFENDER so the toolchain is present on any managed Mac
#   even before MDM has finished pushing Defender.
#
#   Apple's native `container` tool is an alternative runtime but is NOT
#   required and not installed: it is not Docker-API-compatible, so it cannot
#   drive the Dev Containers CLI (podman can).
#

# macOS + Apple Silicon only (podman uses the applehv hypervisor here).
[[ "$DOTS_OS" != "macos" ]] && { log_skip "Not macOS"; return 0; }
[[ "$(uname -m)" != "arm64" ]] && { log_skip "Not Apple Silicon"; return 0; }
[[ "$DOTS_ENV" == "codespaces" ]] && { log_skip "Codespaces"; return 0; }

# podman (Homebrew formula — latest tier; brew can't reliably version-lock).
if ! echo "$BREW_FORMULAE" | grep -q "^podman$"; then
    log_info "Installing podman..."
    brew install podman
fi
echo "$BREW_FORMULA_VERSIONS" | grep -E "^podman " | log_quote || true

# Dev Containers CLI via mise's npm backend (pinned, >=3-4 days behind latest).
# mise (30-mise.sh) put node + its shims dir on PATH earlier in this run.
if command -v mise &>/dev/null; then
    log_info "Installing @devcontainers/cli..."
    MISE_QUIET=1 mise use -g "npm:@devcontainers/cli@0.87.0" 2>&1 | log_quote || true
else
    log_warn "mise not found; skipping devcontainer CLI (run ./install mise first)"
fi

if command -v devcontainer &>/dev/null; then
    log_pass "dev-container toolchain installed"
    echo "podman $(podman --version 2>/dev/null | awk '{print $3}'), devcontainer CLI $(devcontainer --version 2>/dev/null)" | log_quote || true
else
    log_warn "devcontainer CLI not on PATH yet (open a new shell, or run: mise reshim)"
fi
