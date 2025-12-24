#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install mise runtime manager (base installation only).
#   Individual tools are installed in separate scripts (31-python, 32-node, etc.)
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
            [[ -z "$APT_UPDATED" ]] && sudo apt-get update -qq
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
