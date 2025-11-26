#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install the Nix package manager on supported platforms.
#

ensure_prereqs() {
    local missing=()
    for dep in curl xz; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing+=("$dep")
        fi
    done

    if [[ ${#missing[@]} -eq 0 ]]; then
        return 0
    fi

    if command -v brew >/dev/null 2>&1; then
        log_info "Installing ${missing[*]} via Homebrew"
        brew install "${missing[@]}" >/dev/null 2>&1 || return 1
        return 0
    fi

    if command -v pacman >/dev/null 2>&1; then
        log_info "Installing ${missing[*]} via pacman"
        sudo pacman -S --noconfirm --needed "${missing[@]}" >/dev/null 2>&1 || return 1
        return 0
    fi

    if command -v apt-get >/dev/null 2>&1; then
        log_info "Installing ${missing[*]} via apt"
        sudo apt-get update -qq >/dev/null 2>&1 || return 1
        sudo apt-get install -y curl xz-utils >/dev/null 2>&1 || return 1
        return 0
    fi

    log_warn "Unable to install prerequisites automatically (${missing[*]} missing)"
    return 1
}

run_nix_installer() {
    local platform="$1"
    local -a args=()

    case "$platform" in
        linux)
            args+=("--daemon")
            ;;
        darwin)
            args+=("--daemon")
            ;;
        *)
            log_warn "Unsupported platform for Nix installer"
            return 1
            ;;
    esac

    if ! ensure_prereqs; then
        log_warn "Skipping Nix install: prerequisites not satisfied"
        return 1
    fi

    local installer
    installer=$(mktemp)
    if ! curl -fsSL https://nixos.org/nix/install -o "$installer"; then
        log_error "Failed to download Nix installer"
        rm -f "$installer"
        return 1
    fi

    chmod +x "$installer"
    if yes | sh "$installer" "${args[@]}"; then
        log_pass "Nix installation complete"
        rm -f "$installer"
        return 0
    else
        log_error "Nix installer exited with an error"
        rm -f "$installer"
        return 1
    fi
}

main() {
    if command -v nix-env >/dev/null 2>&1 || command -v nix >/dev/null 2>&1; then
        log_info "Nix already installed; skipping"
        return
    fi

    case "${OSTYPE:-}" in
        linux-gnu*)
            log_info "Installing Nix (Linux daemon mode)"
            run_nix_installer "linux"
            ;;
        darwin*)
            log_info "Installing Nix (macOS daemon mode)"
            run_nix_installer "darwin"
            ;;
        *)
            log_warn "Skipping Nix install: unsupported platform (${OSTYPE:-unknown})"
            ;;
    esac
}

main "$@"
unset -f main
unset -f ensure_prereqs
unset -f run_nix_installer
