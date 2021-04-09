#!/usr/bin/env bash
set -euo pipefail

tag=`uuidgen`
docker build . \
    -t dotfiles:$tag \
    --target test

docker run dotfiles:$tag
