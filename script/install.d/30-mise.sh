#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install mise runtime manager and all development tools.
#   Consolidated installation of Python, Node.js, GitHub CLI, Terraform, Firebase, etc.
#

# Skip in Codespaces (use pre-installed versions)
[[ "$DOTS_ENV" == "codespaces" ]] && { log_pass "Skipping in Codespaces"; return 0; }

# Install mise
if ! command -v mise &>/dev/null; then
    log_info "Installing mise..."
    case "$DOTS_PKG" in
        brew)
            brew install mise
            ;;
        apt)
            # https://mise.jdx.dev/getting-started.html#apt-debian-ubuntu
            wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | \
                sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg 1> /dev/null
            echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=amd64] https://mise.jdx.dev/deb stable main" | \
                sudo tee /etc/apt/sources.list.d/mise.list
            sudo apt-get update -qq
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

mise --version

typeset -a MISE_RUNTIMES=(
    "python@3.14.2"
    "node@25.5.0"
)

log_info "Installing runtimes..."
mise install "${MISE_RUNTIMES[@]}"
for tool in "${MISE_RUNTIMES[@]}"; do
    mise use -g "$tool"
done

# Activate mise shims so runtimes (e.g. python3) are available for app installers
eval "$(mise activate bash)"
export PATH="$HOME/.local/share/mise/shims:$PATH"

typeset -a MISE_APPS=(
    "poetry@2.3.2"
    "gh@2.86.0"
    "terraform@1.14.4"
    "firebase@15.5.1"
    "fzf@latest"
    "zoxide@latest"
    "ripgrep@latest"
    "fastfetch@latest"
)

log_info "Installing apps..."
mise install "${MISE_APPS[@]}"
for tool in "${MISE_APPS[@]}"; do
    mise use -g "$tool"
done

# Setup Poetry ZSH completions (XDG compliant)
COMPLETIONS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/completions"
mkdir -p "$COMPLETIONS_DIR"
if [ ! -f "$COMPLETIONS_DIR/_poetry" ]; then
    mise exec -- poetry completions zsh > "$COMPLETIONS_DIR/_poetry"
fi

# Verify installations using mise exec
log_info "Verifying installations..."
mise exec -- python --version
mise exec -- poetry --version
echo "node $(mise exec -- node --version)"
echo "npm $(mise exec -- npm --version)"
mise exec -- gh --version
mise exec -- terraform --version
echo "firebase: $(mise exec -- firebase --version)"
echo "fastfetch: $(mise exec -- fastfetch --version 2>&1 | head -1)"
