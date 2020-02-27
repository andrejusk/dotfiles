#!/usr/bin/env bash
#
# Invokes all test scripts.
#
set -euo pipefail

cd ./tests
poetry install
poetry run pytest
