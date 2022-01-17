#!/usr/bin/env bash
set -eo pipefail

#
# Build image and run bash prompt
#


tag=${TAG:-uuidgen}

docker buildx build . \
    --build-arg UUID=$tag \
    --tag dotfiles:$tag \
    --target source

docker run \
    -it \
    dotfiles:$tag \
    /bin/bash
