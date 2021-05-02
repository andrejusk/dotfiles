#!/usr/bin/env bash
yarn --version

for dep in `jq -r ".node_dependencies[]" $CONFIG`; do
    yarn global add $dep
    yarn global upgrade $dep
done
