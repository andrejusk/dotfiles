#!/usr/bin/env bash
set -eo pipefail

BUCKET=${BUCKET:-"dots.andrejus.dev"}

NAME=$(basename "$0")
REL_DIR=$(dirname "$0")
ABS_DIR=$(readlink -f $REL_DIR/../) # Scripts are nested inside of /scripts

# Publish setup script to public bucket
gsutil cp "$ABS_DIR/scripts/setup.sh" "gs://$BUCKET/setup.sh"
