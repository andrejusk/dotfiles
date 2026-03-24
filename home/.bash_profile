# Switch to zsh if available (chsh doesn't persist in containers/Codespaces)
if [[ -z "${ZSH_VERSION:-}" ]]; then
    if command -v zsh &>/dev/null; then
        exec zsh -l
    else
        printf '\033[38;2;248;140;20m[dots] zsh not found — falling back to bash\033[0m\n' >&2
    fi
fi

# Load .profile, containing login, non-bash related initializations.
[ -f "$HOME/.profile" ] && source "$HOME/.profile"

command -v mise &>/dev/null && eval "$(mise activate bash)"
