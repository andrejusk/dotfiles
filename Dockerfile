#
# ubuntu-base: Base Ubuntu image with sudo user
#
FROM ubuntu:focal AS ubuntu-base

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -qy update
RUN apt-get -qy install --no-install-recommends \
    apt-utils software-properties-common sudo

# Create user with sudo priviledge
RUN useradd -r -u 1001 --create-home -m "test-user"
RUN adduser "test-user" sudo
RUN echo "test-user ALL=(ALL) NOPASSWD: ALL" \
    >>/etc/sudoers


#
# source: Source steps
#
FROM ubuntu-base AS source

ARG DOTFILES_DIR="/home/test-user/.dotfiles"
ADD --chown="test-user" . "$DOTFILES_DIR"
WORKDIR "$DOTFILES_DIR"


#
# install: Install steps
#
FROM source AS install

USER test-user
ENV USER=test-user
ENV UUID="docker"
RUN ./scripts/install.sh


#
# test: Test entrypoint
#
FROM install AS test
ENTRYPOINT [ "tests/run.sh" ]
