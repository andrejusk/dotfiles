#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install gh CLI extensions (idempotent). Runs after 30-mise.sh installs gh.
#

command -v gh >/dev/null 2>&1 || { log_skip "gh not installed"; return 0; }

GH_EXTS=(
    "github/gh-aw"       # agentic workflows: compile/run/update .md workflows
    "github/gh-copilot"  # gh copilot suggest/explain
    "github/gh-shell"    # run shell commands via gh
)

installed="$(gh extension list 2>/dev/null)"
for ext in "${GH_EXTS[@]}"; do
    if echo "$installed" | grep -q "${ext}"; then
        log_skip "${ext} present"
    else
        gh extension install "$ext" 2>&1 | log_quote || true
    fi
done

gh extension upgrade --all 2>&1 | log_quote || true
log_pass "gh extensions installed"
