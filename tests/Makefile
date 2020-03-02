# dotfiles tests Makefile
# ---------------------------------------------------------------------------- #
#	Test commands
# ---------------------------------------------------------------------------- #
.PHONY: test

# Import .bashrc and run test suite
test: SHELL:=/bin/bash
test:
	poetry install
	poetry run pytest
