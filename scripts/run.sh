#!/usr/bin/env bash
set -euo pipefail

tag=$(uuidgen)
docker build . \
    --build-arg UUID=$tag \
    --tag dotfiles:$tag \
    --target install

docker run \
    -v "$(pwd)"/logs:/home/test-user/.dotfiles/logs \
    dotfiles:$tag \
    /bin/bash
