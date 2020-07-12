from ubuntu:bionic as install

# Install sudo and make, git since built-in is skipped
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get -qqy update \
    && apt-get -qqy install curl git make software-properties-common sudo

# Create user with sudo priviledge
ARG USER="test-user"
RUN useradd --create-home -m "$USER" \
    && adduser "$USER" sudo
RUN echo "$USER ALL=(ALL) NOPASSWD: ALL" \
    >>/etc/sudoers

# Filesystem steps
ENV WORKSPACE="/home/$USER/workspace"
ENV LOG_TARGET="STDOUT"
ADD --chown=test-user . "$WORKSPACE/dotfiles"
WORKDIR "$WORKSPACE/dotfiles"

# Install steps
USER test-user
ARG TARGET="all"
RUN make install TARGET=$TARGET

# Test entrypoint
ENTRYPOINT [ "make", "--directory", "tests", "TARGET=$TARGET" ]
