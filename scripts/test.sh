#!/usr/bin/env bash
set -eo pipefail

#
# Build image and run test suite
#


IMAGE=${IMAGE:-"andrejusk/dotfiles"}
tag=${TAG:-uuidgen}

docker buildx build . \
    --build-arg UUID=$tag \
    --cache-from $IMAGE \
    --tag $IMAGE:$tag \
    --target test

docker run $IMAGE:$tag
