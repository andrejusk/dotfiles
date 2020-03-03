from ubuntu:bionic

# ---------------------------------------------------------------------------- #
#   (usually) Cached steps
# ---------------------------------------------------------------------------- #

# See bootstrap.sh
ENV FAST_MODE="true"
ENV WORKSPACE="$HOME/workspace"

# Set Noninteractive
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install sudo for compatibility, git since built-in is skipped, make
RUN apt-get -y update \
    && apt-get -y install sudo git make

# Create user with sudo priviledge
ENV USER="test-user"
RUN useradd --create-home -m "$USER" \
    && adduser "$USER" sudo
RUN echo "$USER ALL=(ALL) NOPASSWD: ALL" \
    >> /etc/sudoers

# ---------------------------------------------------------------------------- #
#   Filesystem copy steps
# ---------------------------------------------------------------------------- #

WORKDIR "$WORKSPACE/dotfiles"
ADD --chown=test-user . .
USER test-user

# ---------------------------------------------------------------------------- #
#   Install steps
# ---------------------------------------------------------------------------- #

RUN make

# ---------------------------------------------------------------------------- #
#   Test steps
# ---------------------------------------------------------------------------- #

WORKDIR "$WORKSPACE/dotfiles/tests"
ENTRYPOINT ["make"]
