#!/usr/bin/env bash
set -euo pipefail

bash -l -c "poetry install && poetry run pytest"
