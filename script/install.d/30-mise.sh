#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install mise runtime manager and all development tools.
#   Consolidated installation of Python, Node.js, Terraform, Firebase, etc.
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

# Define all tools to install
typeset -a MISE_TOOLS=(
    "python@3"
    "poetry@latest"
    "node@lts"
    "terraform@latest"
    "firebase@latest"
)

# Install all tools in parallel
log_info "Installing development tools in parallel..."
mise install --jobs=4 "${MISE_TOOLS[@]}"

# Set global versions
log_info "Setting global versions..."
mise use -g python@3
mise use -g poetry@latest
mise use -g node@lts
mise use -g terraform@latest
mise use -g firebase@latest

# Activate mise environment for current session
eval "$(mise activate bash)"
export PATH="$HOME/.local/share/mise/shims:$PATH"

# Setup Poetry ZSH completions
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [[ -d "$ZSH_CUSTOM/plugins" ]]; then
    POETRY_PLUGIN="$ZSH_CUSTOM/plugins/poetry"
    if [ ! -d "$POETRY_PLUGIN" ]; then
        mkdir -p "$POETRY_PLUGIN"
        mise exec -- poetry completions zsh > "$POETRY_PLUGIN/_poetry"
    fi
fi

# Verify installations using mise exec
log_info "Verifying installations..."
mise exec -- python --version
mise exec -- poetry --version
echo "node $(mise exec -- node --version)"
echo "npm $(mise exec -- npm --version)"
mise exec -- terraform --version
echo "firebase: $(mise exec -- firebase --version)"
