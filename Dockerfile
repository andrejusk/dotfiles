from ubuntu:bionic

# ---------------------------------------------------------------------------- #
#   (usually) Cached steps
# ---------------------------------------------------------------------------- #

# Set variables up, FAST_MODE to prevent git and upgrade
ENV FAST_MODE="true"
ENV WORKSPACE="$HOME/workspace"

# Install sudo for compatibility, git since it is skipped, make
# Triple quiet mode (-qq implies -y, pipe to /dev/null)
RUN apt-get -qq update && \
    apt-get -qq install sudo git make \
     < /dev/null > /dev/null

# Create user with sudo priviledge
ENV USER="test-user"
RUN useradd --create-home -m $USER && \
    adduser $USER sudo
RUN echo "$USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# ---------------------------------------------------------------------------- #
#   Filesystem copy steps
# ---------------------------------------------------------------------------- #

# Copy dotfiles in
ADD --chown=test-user . "$WORKSPACE/dotfiles"
WORKDIR "$WORKSPACE/dotfiles"

# Allow execution
RUN chmod +x ./bootstrap.sh

# ---------------------------------------------------------------------------- #
#   Install steps
# ---------------------------------------------------------------------------- #

# Run installer
USER test-user
RUN make install

# ---------------------------------------------------------------------------- #
#   Test steps
# ---------------------------------------------------------------------------- #

# Run tests
RUN make test || true
