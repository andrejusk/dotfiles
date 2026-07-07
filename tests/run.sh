#!/usr/bin/env bash
set -euo pipefail

# Use the mise-provisioned Python (3.14.x); never let uv download a managed
# interpreter, so the test run stays hermetic and offline-safe.
export UV_PYTHON_PREFERENCE=system
export UV_PYTHON_DOWNLOADS=never

bash -l -c "uv sync && uv run pytest"
