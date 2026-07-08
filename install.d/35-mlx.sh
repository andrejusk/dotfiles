#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (Apple Silicon only) Install Apple MLX local-LLM tooling (mlx-lm) via mise.
#   Provides mlx_lm.generate / mlx_lm.chat / mlx_lm.server for running local
#   models. Tooling only - models are downloaded on first use.
#
#   Recommended model for this machine (M1 Max, 64GB):
#     mlx-community/Qwen3-Coder-30B-A3B-Instruct-4bit
#   First run, e.g.:
#     mlx_lm.server --model mlx-community/Qwen3-Coder-30B-A3B-Instruct-4bit
#

# macOS only
[[ "$DOTS_OS" != "macos" ]] && { log_skip "Not macOS"; return 0; }

# Apple Silicon only (MLX requires a Metal GPU on arm64)
if [[ "$(uname -m)" != "arm64" ]]; then
    log_skip "Not Apple Silicon"
    return 0
fi

# Skip in Codespaces (no local GPU / not the target environment)
[[ "$DOTS_ENV" == "codespaces" ]] && { log_skip "Codespaces"; return 0; }

# mise manages the tool (pinned via the pipx backend). Requires 30-mise.sh first.
if ! command -v mise &>/dev/null; then
    log_warn "Skipping MLX install: mise not found (run 30-mise first)"
    return 0
fi

log_info "Installing mlx-lm..."
# uv provides the fast installer engine for mise's pipx backend
MISE_QUIET=1 mise use -g "uv@0.11.21" 2>&1 | log_quote || true
MISE_QUIET=1 mise use -g "pipx:mlx-lm@0.31.3" 2>&1 | log_quote || true

# mlx-lm 0.31.3 requires transformers>=5.0 but breaks importing on 5.12+ (a
# tokenizer register-API change). If the server can't import, pin transformers
# <5.12 inside the pipx venv. Idempotent: only runs when actually broken.
# (dev-model runs the server in its own pinned uv env and is unaffected.)
mlx_py="$(mise where pipx:mlx-lm 2>/dev/null)/mlx-lm/bin/python"
if [[ -x "$mlx_py" ]] && ! "$mlx_py" -c 'import mlx_lm.server' &>/dev/null; then
    log_info "Pinning transformers<5.12 (mlx-lm 0.31.3 incompatibility)..."
    uv pip install --python "$mlx_py" 'transformers<5.12' 2>&1 | log_quote || true
fi

log_pass "MLX tooling installed"
mise ls --current 2>/dev/null | grep "mlx-lm" | awk '{printf "%s %s\n", $1, $2}' | log_quote
