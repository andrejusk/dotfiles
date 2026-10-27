#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Start the macmon telemetry server as a per-user LaunchAgent.
#

[[ "$DOTS_OS" != "macos" ]] && { log_skip "macOS only"; return 0; }
[[ "$(uname -m)" != "arm64" ]] && { log_skip "Apple Silicon only"; return 0; }

if ! command -v macmon &>/dev/null; then
    log_warn "macmon not installed (run ./install mise first)"
    return 0
fi

log_info "Configuring macmon telemetry service..."
if macmon serve --host 127.0.0.1 --install 2>&1 | log_quote; then
    log_pass "macmon telemetry service active"
else
    log_warn "Could not start macmon telemetry service"
fi
