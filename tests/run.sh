#!/usr/bin/env bash
set -euo pipefail

poetry install && poetry run pytest
