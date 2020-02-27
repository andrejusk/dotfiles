.PHONY: clean
clean:
	rm -f .dotlock

.PHONY: install
install:
	bash bootstrap.sh

.PHONY: test
test:
	bash test.sh

.PHONY: build
build:
	docker build . -t dotfiles:latest

.PHONY: run
run:
	docker run -it dotfiles:latest /bin/bash
