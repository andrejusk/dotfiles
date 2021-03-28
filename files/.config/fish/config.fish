# Only execute in interactive shell
if status --is-interactive
    # Cross-shell setup
    if begin; test -e $HOME/.profile; and type -q replay; end
        replay "source $HOME/.profile"
    end

    # Fish specific
    set fish_greeting
    if type -q base16-seti
        base16-seti
    end
end
