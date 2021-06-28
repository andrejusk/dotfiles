#!/usr/bin/env bash
set -euo pipefail

# pyenv install --skip-existing && pyenv shell
poetry install && poetry run pytest
