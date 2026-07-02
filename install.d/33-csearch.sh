#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (Defender Macs only) Keep the csearch per-repo trigram indexes fresh
#   automatically. Installs fswatch and loads a LaunchAgent that runs
#   `csearch-watch`, which watches the indexed repos (FSEvents — event-driven,
#   no polling) and incrementally reindexes only changed files after a short
#   debounce.
#
#   This whole subsystem exists to work around Microsoft Defender's per-file
#   open() scan making rg slow on huge repos, so it is gated on DOTS_DEFENDER
#   (see script/install). Indexes are built by ~/Workspace/bootstrap-workspace.sh;
#   the csearch/cindex binaries come from 30-mise.sh (also DOTS_DEFENDER-gated);
#   the scripts are stowed by 23-stow.sh. macOS-only (fswatch + launchd).
#

# Defender Macs only — where the AV open() tax makes an index worthwhile.
[[ -z "$DOTS_DEFENDER" ]] && { log_skip "No enforced Defender (rg is fast here)"; return 0; }

# Needs the csearch tooling (mise) and the stowed helper scripts.
if ! command -v cindex &>/dev/null; then
    log_skip "codesearch not installed (run ./install mise first)"
    return 0
fi
if [[ ! -x "$HOME/.local/bin/csearch-watch" ]]; then
    log_skip "csearch-watch not stowed (run ./install stow first)"
    return 0
fi

# Install fswatch (no mise backend; Homebrew per the native-package-manager ADR).
if ! echo "$BREW_FORMULAE" | grep -q "^fswatch$"; then
    log_info "Installing fswatch..."
    brew install fswatch
fi
echo "$BREW_FORMULA_VERSIONS" | grep -E "^fswatch " | log_quote || true

# Generate a per-user LaunchAgent (absolute paths — launchd does not expand $HOME).
LABEL="uk.andrejus.csearch-watch"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
WATCH="$HOME/.local/bin/csearch-watch"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/csearch"
mkdir -p "$HOME/Library/LaunchAgents" "$CACHE"

cat > "$PLIST" <<PLIST_EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key><string>$LABEL</string>
    <key>ProgramArguments</key>
    <array><string>$WATCH</string></array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>HOME</key><string>$HOME</string>
        <key>PATH</key><string>$HOME/.local/bin:$HOME/.local/share/mise/shims:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>
    <key>RunAtLoad</key><true/>
    <key>KeepAlive</key><true/>
    <key>ProcessType</key><string>Background</string>
    <key>LowPriorityIO</key><true/>
    <key>Nice</key><integer>10</integer>
    <key>StandardOutPath</key><string>$CACHE/watch.log</string>
    <key>StandardErrorPath</key><string>$CACHE/watch.log</string>
</dict>
</plist>
PLIST_EOF

# (Re)load idempotently — prefer modern launchctl, fall back to load/unload.
uid=$(id -u)
launchctl bootout "gui/$uid/$LABEL" 2>/dev/null || true
if launchctl bootstrap "gui/$uid" "$PLIST" 2>/dev/null; then
    log_pass "csearch-watch LaunchAgent loaded (auto-refresh active)"
elif launchctl unload "$PLIST" 2>/dev/null; launchctl load -w "$PLIST" 2>/dev/null; then
    log_pass "csearch-watch LaunchAgent loaded (auto-refresh active)"
else
    log_warn "Could not load $LABEL; load manually: launchctl bootstrap gui/$uid $PLIST"
fi
unset LABEL PLIST WATCH CACHE uid
