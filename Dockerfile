#
# debian-base: Base Debian image with sudo user
#
FROM debian:buster AS debian-base

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
sudo \
uuid-runtime

# Create user with sudo priviledge
RUN useradd -r -u 1001 --create-home -m "test-user" && \
    adduser "test-user" sudo && \
    echo "test-user ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers

#
# source: Base image with source copied over
#
FROM debian-base AS source

ARG DOTFILES_DIR="/home/test-user/.dotfiles"
RUN mkdir ${DOTFILES_DIR} && chown test-user ${DOTFILES_DIR}

ADD --chown="test-user" files "$DOTFILES_DIR/files"
ADD --chown="test-user" scripts "$DOTFILES_DIR/scripts"
WORKDIR "$DOTFILES_DIR"


#
# install: Installation steps
#
FROM source AS install

USER test-user
ENV USER=test-user
ARG UUID="docker"
RUN ./scripts/install.sh


#
# test: Test entrypoint
#
FROM install AS test

ADD --chown="test-user" tests "$DOTFILES_DIR/tests"
WORKDIR "${DOTFILES_DIR}/tests"
ENTRYPOINT [ "./run.sh" ]
