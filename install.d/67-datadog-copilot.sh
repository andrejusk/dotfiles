#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install the official Datadog plugin for GitHub Copilot CLI.
#

if [[ "$DOTS_ENV" == "codespaces" ]]; then
    log_skip "Datadog Copilot plugin is local-only"
    return 0
fi

if ! command -v copilot &>/dev/null; then
    log_warn "Copilot CLI not found; skipping Datadog plugin"
    return 0
fi

if copilot plugin list 2>/dev/null | grep -Fq "datadog@awesome-copilot"; then
    log_pass "Datadog Copilot plugin installed"
    return 0
fi

copilot plugin install datadog@awesome-copilot
log_pass "Datadog Copilot plugin installed"
