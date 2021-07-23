#!/usr/bin/env bash
set -euo pipefail

IMAGE=${IMAGE:-"andrejusk/dotfiles"}
tag=${TAG:-uuidgen}

docker build . \
    --build-arg UUID=$tag \
    --cache-from $IMAGE \
    --tag $IMAGE:$tag \
    --target test

docker run \
    -v "$(pwd)"/logs:/home/test-user/.dotfiles/logs \
    $IMAGE:$tag
