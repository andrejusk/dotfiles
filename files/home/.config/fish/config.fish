# Only execute in interactive shell
if status is-interactive

    # Fish specific
    set fish_greeting
    set --global hydro_symbol_prompt "λ"
    set --global hydro_symbol_git_dirty "~"
    if type -q base16-seti
        base16-seti
    end

    # Cross-shell setup
    if begin; test -e $HOME/.profile; and type -q replay; end
        replay "source $HOME/.profile"
    end

    pyenv init - | source
    poetry completions fish > ~/.config/fish/completions/poetry.fish

end
