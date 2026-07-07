#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install/configure git and enable the fsmonitor daemon where it is supported.
#
#   fsmonitor (git's built-in FSEvents/inotify daemon) avoids lstat'ing the
#   whole working tree on every `git status`, a large win on big repos —
#   especially under endpoint AV (Microsoft Defender), whose per-file open()
#   scan makes status scale with file count (~1.2-2.6s -> ~0.25s on a
#   very large monorepo). We enable it ONLY where the daemon actually works, probed at
#   runtime, so unsupported platforms (git without the daemon: musl/Alpine, iSH,
#   git < 2.44 on Linux) skip silently with no warnings. The setting is written
#   to a machine-local include (~/.gitconfig.perf) so it never dirties the
#   committed, cross-platform gitconfig.
#

# Returns 0 iff `core.fsmonitor=true` works here with no warnings/errors. Probes
# a throwaway repo rather than guessing from version/OS, so the answer reflects
# this exact git build and filesystem.
_dots_git_fsmonitor_supported() {
    local tmp out rc
    tmp=$(mktemp -d) || return 1
    if ! git init -q "$tmp" 2>/dev/null; then rm -rf "$tmp"; return 1; fi
    out=$(cd "$tmp" && git -c core.fsmonitor=true -c core.untrackedCache=true \
        status --porcelain 2>&1)
    rc=$?
    git -C "$tmp" fsmonitor--daemon stop >/dev/null 2>&1 || true
    rm -rf "$tmp"
    [[ $rc -eq 0 ]] && ! printf '%s' "$out" \
        | grep -qiE 'warning|fatal|error|not supported|not a git command'
}

# Install git unless present (pre-installed in the Codespaces universal image).
if ! command -v git &>/dev/null; then
    if [[ "$DOTS_ENV" == "codespaces" ]]; then
        log_skip "git pre-installed in Codespaces"
    else
        case "$DOTS_PKG" in
            apt)    sudo apt-get install -qq git ;;
            pacman) sudo pacman -S --noconfirm git ;;
            brew)   brew install git ;;
            *)      log_warn "Skipping git install: no supported package manager found"; return 0 ;;
        esac
    fi
fi
command -v git &>/dev/null || { log_warn "git unavailable; skipping config"; return 0; }

# Enable fsmonitor where supported (runs on every platform incl. Codespaces).
_dots_git_perf="$HOME/.gitconfig.perf"
if _dots_git_fsmonitor_supported; then
    git config --file "$_dots_git_perf" core.fsmonitor true
    git config --file "$_dots_git_perf" core.untrackedCache true
    log_pass "git fsmonitor enabled (fast status on large repos)"
else
    # Idempotent: drop a stale setting if this machine no longer supports it.
    [[ -f "$_dots_git_perf" ]] && rm -f "$_dots_git_perf"
    log_skip "git fsmonitor unsupported here; left disabled (no warnings)"
fi
unset -f _dots_git_fsmonitor_supported
unset _dots_git_perf

log_pass "git configured"
git --version | log_quote
