if status --is-interactive
    # Cross-shell setup
    if begin; test -e ~/.bash_profile; and type -q bax; end
        bax "source ~/.bash_profile"
    end
    
    # Fish specific
    set fish_greeting
    if type -q base16-seti
        base16-seti
    end
end
