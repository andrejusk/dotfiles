# Only execute in interactive shell
if status is-interactive

    # Fish specific
    set fish_greeting
    set --global hydro_symbol_prompt "λ"
    set --global hydro_symbol_git_dirty "~"

    # Cross-shell setup
    if begin; test -e $HOME/.profile; and type -q replay; end
        replay "source $HOME/.profile"
    else
        echo "dots warn: .profile could not be loaded"
    end

    pyenv init - | source

end
