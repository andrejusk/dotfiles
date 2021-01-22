set --global hydro_symbol_prompt "\$"
set --global hydro_symbol_git_dirty "~"
set --global hydro_fetch true

if status --is-interactive
    # Cross-shell setup
    if begin; test -e ~/.bash_profile; and type -q replay; end
        replay "source ~/.bash_profile"
    end

    # Fish specific
    set fish_greeting
    if type -q base16-seti
        base16-seti
    end
end
