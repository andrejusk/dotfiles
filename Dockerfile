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

ADD --chown=test-user . "$WORKSPACE/dotfiles"
WORKDIR "$WORKSPACE/dotfiles"

# ---------------------------------------------------------------------------- #
#   Install steps
# ---------------------------------------------------------------------------- #

USER test-user
RUN make install

# ---------------------------------------------------------------------------- #
#   Test steps
# ---------------------------------------------------------------------------- #

CMD ["cd", "tests", "&&", "make"]
