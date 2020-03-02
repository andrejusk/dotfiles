# dotfiles Makefile
# ---------------------------------------------------------------------------- #
#	Local target commands (warning: affects local environment)
# ---------------------------------------------------------------------------- #
.PHONY: install clean

# Install dotfiles locally
install: SHELL:=/bin/bash
install:
	chmod +x ./bootstrap.sh
	./bootstrap.sh

# Clean up after install
clean:
	rm -f .dotlock

# ---------------------------------------------------------------------------- #
#	Docker commands
# ---------------------------------------------------------------------------- #
.PHONY: build run

# Build and tag latest docker image
build:
	docker build . -t dotfiles:latest

# Run latest docker container
run:
	docker run -it dotfiles:latest /bin/bash
