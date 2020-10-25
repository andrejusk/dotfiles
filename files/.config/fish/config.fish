# ---------------------------------------------------------------------------- #
#   Cross-shell (only import if environment has been setup)
# ---------------------------------------------------------------------------- #
if begin; test -e ~/.bash_profile; and type -q bass; end
	bass source ~/.bash_profile
end

# ---------------------------------------------------------------------------- #
#   Fish specific
# ---------------------------------------------------------------------------- #
set fish_greeting
base16-seti
