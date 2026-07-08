#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Configure host-level MCP servers for Copilot CLI and OpenCode.
#
#   Copilot's public MCP base is tracked as ~/.copilot/mcp-config.base.json.
#   Machine-local/private additions (for example pre-registered OAuth client
#   IDs) live in ~/.copilot/mcp-config.local.json, which is not tracked. This
#   script merges them into the real ~/.copilot/mcp-config.json that Copilot
#   reads. OpenCode's public config is tracked directly.
#

COPILOT_MCP="$HOME/.copilot/mcp-config.json"
COPILOT_MCP_BASE="$HOME/.copilot/mcp-config.base.json"
COPILOT_MCP_LOCAL="$HOME/.copilot/mcp-config.local.json"
OPENCODE_MCP="$HOME/.config/opencode/opencode.json"

_dots_validate_json() {
    local label="$1" path="$2"
    if [[ ! -f "$path" ]]; then
        log_warn "$label MCP config missing: $path (run ./install stow)"
        return 0
    fi
    if command -v python3 &>/dev/null; then
        python3 -m json.tool "$path" >/dev/null
        log_pass "$label MCP config valid"
    else
        log_warn "python3 not found; skipping $label MCP JSON validation"
    fi
}

_dots_build_copilot_mcp() {
    if [[ ! -f "$COPILOT_MCP_BASE" ]]; then
        log_warn "Copilot MCP base missing: $COPILOT_MCP_BASE (run ./install stow)"
        return 0
    fi
    if ! command -v python3 &>/dev/null; then
        log_warn "python3 not found; cannot merge Copilot MCP config"
        return 0
    fi
    python3 - "$COPILOT_MCP_BASE" "$COPILOT_MCP_LOCAL" "$COPILOT_MCP" <<'PY'
import json
import os
import sys

base_path, local_path, out_path = sys.argv[1:4]

def load(path):
    with open(path) as fh:
        return json.load(fh)

cfg = load(base_path)
if os.path.exists(local_path):
    local = load(local_path)
    cfg.setdefault("mcpServers", {}).update(local.get("mcpServers", {}))
    for key, value in local.items():
        if key != "mcpServers":
            cfg[key] = value

if os.environ.get("DOTS_ENV") == "codespaces":
    servers = cfg.get("mcpServers", {})
    playwright = servers.get("playwright")
    if playwright:
        playwright = dict(playwright)
        playwright["args"] = [
            "-y",
            "@playwright/mcp@0.0.77",
            "--browser",
            "chromium",
            "--headless",
            "--isolated",
            "--block-service-workers",
            "--viewport-size",
            "1440x1000",
        ]
        cfg["mcpServers"] = {"playwright": playwright}

tmp = f"{out_path}.tmp"
with open(tmp, "w") as fh:
    json.dump(cfg, fh, indent=2)
    fh.write("\n")
os.replace(tmp, out_path)
PY
    log_pass "Copilot MCP config generated"
}

_dots_build_copilot_mcp
_dots_validate_json "Copilot" "$COPILOT_MCP"
_dots_validate_json "OpenCode" "$OPENCODE_MCP"

if command -v python3 &>/dev/null && [[ -f "$COPILOT_MCP" ]]; then
    if python3 - "$COPILOT_MCP" <<'PY'
import json, sys
cfg = json.load(open(sys.argv[1]))
slack = cfg.get("mcpServers", {}).get("slack", {})
ok = (
    slack.get("type") == "http"
    and slack.get("url") == "https://mcp.slack.com/mcp"
    and isinstance(slack.get("oauthClientId"), str)
    and slack.get("oauthPublicClient") is True
)
raise SystemExit(0 if ok else 1)
PY
    then
        log_pass "Slack MCP OAuth config present"
    else
        log_skip "Slack MCP local overlay not configured"
    fi
fi

if command -v npx &>/dev/null; then
    log_info "Priming pinned host MCP packages..."
    npx -y @playwright/mcp@0.0.77 --version 2>&1 | log_quote || true
    if [[ "$DOTS_ENV" != "codespaces" ]]; then
        npx -y chrome-devtools-mcp@1.5.0 --version 2>&1 | log_quote || true
    fi
else
    log_warn "npx not found; skipping MCP package warm-up (run ./install mise)"
fi

if command -v gh &>/dev/null; then
    log_info "Configured Copilot MCP servers..."
    gh copilot -- mcp list 2>&1 | log_quote || true
else
    log_warn "gh not found; skipping Copilot MCP listing"
fi

log_info "Private Copilot MCP overlay path: $COPILOT_MCP_LOCAL"
log_pass "Host MCP config ready"
