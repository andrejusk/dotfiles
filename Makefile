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
	docker build . -t dotfiles --build-arg

# Run tests in docker container (args to specify test)
test:
	docker build . -t dotfiles --build-args
	docker run dotfiles

# Launch bash in docker container
start:
	docker run -it dotfiles /bin/bash
