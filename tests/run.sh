#!/usr/bin/env bash
set -euo pipefail

# FIXME poetry not found, or nix home-manager source fails
# source ~/.profile

poetry install && poetry run pytest
