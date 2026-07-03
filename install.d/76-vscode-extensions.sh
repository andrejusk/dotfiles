#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Reinstall the local VS Code extension set. Runs after 74-vscode.sh (which
#   installs the `code` cask + CLI). Extensions inside Codespaces / dev
#   containers are provisioned per-devcontainer, so this only reproduces the
#   LOCAL desktop profile — skipped in Codespaces and wherever `code` is absent
#   (so it's a portable no-op rather than macOS-gated).
#

# Skip in Codespaces (extensions there are managed per-devcontainer)
[[ "$DOTS_ENV" == "codespaces" ]] && { log_skip "Codespaces (extensions managed per-devcontainer)"; return 0; }

if ! command -v code &>/dev/null; then
    log_skip "VS Code 'code' CLI not found"
    return 0
fi

# Local desktop extensions. Unpinned on purpose: VS Code auto-updates
# extensions, so they sit in the brew/GUI 'latest' tier, not the pinned mise
# tier. (Insiders keeps its own separate set — intentionally not managed here.)
extensions=(
    # Editing / motions
    vscodevim.vim
    vspacecode.vspacecode
    vspacecode.whichkey
    kahole.magit
    usernamehw.errorlens
    bodil.file-browser
    jacobdufault.fuzzy-search
    # Theme / UI
    github.github-vscode-theme
    pkief.material-icon-theme
    johnpapa.vscode-peacock
    # Languages / formatting
    editorconfig.editorconfig
    redhat.vscode-yaml
    be5invis.toml
    # Remote clients (run locally to connect out to SSH / containers / codespaces)
    github.codespaces
    ms-vscode-remote.remote-ssh
    ms-vscode-remote.remote-containers
    ms-vscode.remote-server
)

# Query installed extensions once; only install the missing ones (idempotent).
installed=$(code --list-extensions 2>/dev/null)
for ext in "${extensions[@]}"; do
    if echo "$installed" | grep -qixF "$ext"; then
        continue
    fi
    log_info "Installing VS Code extension: $ext"
    code --install-extension "$ext" --force 2>&1 | log_quote || true
done
unset extensions installed ext

log_pass "VS Code extensions installed"
echo "$(code --list-extensions 2>/dev/null | wc -l | tr -d ' ') extensions present" | log_quote || true
