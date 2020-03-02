# dotfiles Makefile
# ---------------------------------------------------------------------------- #
#	Local target commands (warning: affects local environment)
# ---------------------------------------------------------------------------- #
.PHONY: install clean

# Install dotfiles locally
install:
	./bootstrap.sh

# Clean up after install
clean:
	rm -f .dotlock

# ---------------------------------------------------------------------------- #
#	Docker commands
# ---------------------------------------------------------------------------- #
.PHONY: build run use

# Build and tag docker image
build:
	docker build . -t dotfiles

# Run tests in docker container
run:
	docker run dotfiles

# Launch bash in docker container
use:
	docker run -it dotfiles /bin/bash
