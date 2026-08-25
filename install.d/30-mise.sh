#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install mise runtime manager and all development tools.
#   Consolidated installation of Python, Node.js, GitHub CLI, Terraform, Firebase, etc.
#

typeset -a MISE_APPS=()

# Codespaces only needs tools required by the shell configuration. Optional
# convenience tools stay platform-managed or absent, and mise itself is skipped
# when the image already provides everything required.
if [[ "$DOTS_ENV" == "codespaces" ]]; then
    typeset -a codespaces_specs=(
        "bat@latest"
        "fzf@latest"
        "zoxide@latest"
        "ripgrep@latest"
        "delta@latest"
    )
    typeset -a codespaces_bins=(bat fzf zoxide rg delta)

    for i in "${!codespaces_specs[@]}"; do
        if command -v "${codespaces_bins[$i]}" &>/dev/null; then
            log_skip "${codespaces_bins[$i]} provided by Codespaces"
        else
            MISE_APPS+=("${codespaces_specs[$i]}")
        fi
    done

    unset codespaces_specs codespaces_bins i

    if (( ${#MISE_APPS[@]} == 0 )); then
        bat cache --build &>/dev/null || true
        log_skip "Required CLI tools provided by Codespaces; skipping mise"
        unset MISE_APPS
        return 0
    fi
fi

# Install mise
if ! command -v mise &>/dev/null; then
    log_info "Installing mise..."
    case "$DOTS_PKG" in
        brew)
            brew install mise
            ;;
        apt)
            # https://mise.jdx.dev/getting-started.html#apt-debian-ubuntu
            sudo install -dm 755 /etc/apt/keyrings
            wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | \
                sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg 1> /dev/null
            # Derive the arch (amd64/arm64) so this works on both x86_64 CI and
            # arm64 machines/containers rather than assuming amd64.
            echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=$(dpkg --print-architecture)] https://mise.jdx.dev/deb stable main" | \
                sudo tee /etc/apt/sources.list.d/mise.list
            # Refresh only the newly added repository; the distro indexes were
            # already refreshed by 11-apt.sh.
            sudo apt-get update -qq \
                -o Dir::Etc::sourcelist="sources.list.d/mise.list" \
                -o Dir::Etc::sourceparts="-" \
                -o APT::Get::List-Cleanup="0"
            sudo apt-get install -qq mise
            ;;
        pacman)
            yay -S --noconfirm mise
            ;;
        *)
            # Fallback: curl install
            log_info "Using curl installer..."
            curl https://mise.jdx.dev/install.sh | sh
            # Add to PATH for current session
            export PATH="$HOME/.local/bin:$PATH"
            ;;
    esac
fi

echo "mise $(MISE_QUIET=1 mise --version)" | log_quote

# Skip runtimes in Codespaces (use pre-installed versions)
if [[ "$DOTS_ENV" != "codespaces" ]]; then
    typeset -a MISE_RUNTIMES=(
        "python@3.14.6"
        "node@26.3.0"
        "bun@latest"
        "rust@latest"
        "go@1.26.4"   # general runtime (also builds codesearch on Defender Macs)
    )

    log_info "Installing runtimes..."
    MISE_QUIET=1 mise install "${MISE_RUNTIMES[@]}" 2>&1 | log_quote || true
    MISE_QUIET=1 mise use -g "${MISE_RUNTIMES[@]}" 2>&1 | log_quote || true
fi

# Codespaces should prefer its platform-managed tools and runtimes. Keep mise
# shims as a fallback rather than allowing the repo-local mise.toml to shadow
# the image's Node.js.
if [[ "$DOTS_ENV" == "codespaces" ]]; then
    export PATH="$PATH:$HOME/.local/share/mise/shims"
else
    eval "$(mise activate bash)"
    export PATH="$HOME/.local/share/mise/shims:$PATH"
fi

if [[ "$DOTS_ENV" != "codespaces" ]]; then
    MISE_APPS=(
        "bat@latest"
        "fzf@latest"
        "zoxide@latest"
        "ripgrep@latest"
        "delta@latest"
        "eza@latest"
        "fd@latest"
        "sd@latest"
        "bottom@0.14.1"
        "ubi:dalance/procs@latest"
        "aqua:tealdeer-rs/tealdeer@1.9.0"
        # uv: self-contained static binary (mise core backend), so no Python
        # interpreter/venv is needed to install it. This avoids poetry's
        # official installer picking up the Command Line Tools python3.9,
        # whose relocatable build cannot create venvs without symlinks.
        "uv@latest"
        "gh@2.94.0"
        "terraform@1.15.6"
        "firebase@15.20.0"
        "ubi:sharkdp/hyperfine@1.20.0"
        "fastfetch@latest"
        "glow@latest"
    )
fi

# Trigram code search — only where endpoint AV (Microsoft Defender) makes rg
# slow. Defender scans every file open(), so rg scales with file count and a
# single search over a huge monorepo takes ~a minute;
# csearch answers selective queries in <1s off a prebuilt index. No release
# binaries exist, so build from source via the go runtime above. Gated on
# DOTS_DEFENDER so lean/personal machines (fast rg) skip it. Indexes are built
# and kept fresh by bootstrap-workspace.sh + install.d/33-csearch.sh.
if [[ -n "$DOTS_DEFENDER" ]]; then
    MISE_APPS+=(
        "go:github.com/google/codesearch/cmd/cindex@v1.2.0"
        "go:github.com/google/codesearch/cmd/csearch@v1.2.0"
    )
fi

log_info "Installing apps..."
if (( ${#MISE_APPS[@]} )); then
    if [[ "$DOTS_ENV" == "codespaces" ]]; then
        # Run outside the checkout so its mise.toml does not install a
        # repo-specific Node.js over the Codespaces-provided runtime.
        (cd "$HOME" && MISE_QUIET=1 mise use -g "${MISE_APPS[@]}") 2>&1 | log_quote
    else
        MISE_QUIET=1 mise use -g "${MISE_APPS[@]}" 2>&1 | log_quote || true
    fi
else
    log_skip "All apps provided by Codespaces"
fi

# Rebuild bat theme cache with mise-installed bat (must match delta's syntect version)
bat cache --build &>/dev/null || true

if [[ "$DOTS_ENV" != "codespaces" ]]; then
    # Setup uv ZSH completions (XDG compliant)
    COMPLETIONS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/completions"
    mkdir -p "$COMPLETIONS_DIR"
    # Guard on uv actually being installed: a partial `mise use` (e.g. a tool
    # with no build for this arch) shouldn't abort the whole install here.
    if [ ! -f "$COMPLETIONS_DIR/_uv" ] && mise which uv &>/dev/null; then
        mise exec -- uv generate-shell-completion zsh > "$COMPLETIONS_DIR/_uv"
    fi
fi

log_pass "mise tools installed"
if [[ "$DOTS_ENV" == "codespaces" ]]; then
    (cd "$HOME" && mise ls --current 2>/dev/null) | awk '{printf "%s %s\n", $1, $2}' | log_quote
else
    mise ls --current 2>/dev/null | awk '{printf "%s %s\n", $1, $2}' | log_quote
fi
