# ---------------------------------------------------------------------------- #
#   Cross-shell (only import if environment has been setup)
# ---------------------------------------------------------------------------- #
if begin; test -e ~/.profile; and type -q bass; end
	bass source ~/.profile
end

# ---------------------------------------------------------------------------- #
#   Fish specific
# ---------------------------------------------------------------------------- #
set fish_greeting

set -gx FZF_DEFAULT_COMMAND  'rg --files --no-ignore-vcs --hidden'
