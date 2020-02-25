# Ensure fisher is installed
if not functions -q fisher
    set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
    curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
    fish -c fisher
end

# Poetry
set -gx PATH $HOME/.poetry/bin $PATH

# Wipe greeting
set fish_greeting
