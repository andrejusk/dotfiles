#
# debian-base: Base Debian image with sudo user
#
FROM debian:bookworm-slim AS base

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -qq update
RUN apt-get -qq install --no-install-recommends \
    bc \
    curl \
    gnupg \
    gnupg2 \
    lsb-release \
    openssh-client \
    software-properties-common \
    sudo \
    wget

# Create user with sudo priviledge
RUN useradd -r -u 1001 --create-home -m "test-user"
RUN echo "test-user ALL=(ALL) NOPASSWD: ALL" \
    >>/etc/sudoers

#
# source: Base image with source copied over
#
FROM base AS source

ARG DOTFILES_DIR="/workdir/.dotfiles"
RUN mkdir -p "$DOTFILES_DIR"
RUN chown -R "test-user" "$DOTFILES_DIR"

ADD --chown="test-user" files "$DOTFILES_DIR/files"
ADD --chown="test-user" script "$DOTFILES_DIR/script"
WORKDIR "$DOTFILES_DIR"


#
# install: Installation steps
#
FROM source AS install

ENV USER="test-user"
ENV SKIP_SUDO_CHECK="true"
ENV SKIP_SSH_CONFIG="true"
ENV SKIP_DOCKER_CONFIG="true"

USER test-user
ARG UUID="docker"
RUN ./script/install


#
# test: Test entrypoint
#
FROM install AS test

ADD --chown="test-user" tests "$DOTFILES_DIR/tests"
WORKDIR "$DOTFILES_DIR/tests"
ENTRYPOINT [ "./run.sh" ]
