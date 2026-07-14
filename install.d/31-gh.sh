#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install gh CLI extensions (idempotent). Runs after 30-mise.sh installs gh.
#

command -v gh >/dev/null 2>&1 || { log_skip "gh not installed"; return 0; }

GH_EXTS=(
    "github/gh-aw"       # agentic workflows: compile/run/update .md workflows
    "github/gh-shell"    # run shell commands via gh
)

# `|| true` so a non-zero exit (e.g. fresh/unauthenticated gh with no
# extensions configured yet) does not abort under the runner's `set -e`.
installed="$(gh extension list 2>/dev/null || true)"
for ext in "${GH_EXTS[@]}"; do
    if echo "$installed" | grep -q "${ext}"; then
        log_skip "${ext} present"
    else
        gh extension install "$ext" 2>&1 | log_quote || true
    fi
done

gh extension upgrade --all 2>&1 | log_quote || true

# The Copilot CLI downloaded by `gh copilot` is not a gh extension. Update it
# through this managed pipeline because interactive auto-updates are disabled.
gh copilot -- update 2>&1 | log_quote || true

log_pass "gh extensions installed"
