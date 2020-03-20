# dotfiles Makefile
# ---------------------------------------------------------------------------- #
#	Local target commands (warning: affects local environment)
# ---------------------------------------------------------------------------- #
.PHONY: clean

# Install dotfiles locally
all:
	./bootstrap.sh

# Clean up after install
clean:
	rm -f .dotlock

# ---------------------------------------------------------------------------- #
#	Docker commands
# ---------------------------------------------------------------------------- #
.PHONY: build test start

# Build and tag docker image
build:
	docker build . -t dotfiles:latest

# Run tests in docker container (args to specify test)
test:
	docker run dotfiles:latest

# Launch bash in docker container
start:
	docker run -it dotfiles:latest /bin/bash
