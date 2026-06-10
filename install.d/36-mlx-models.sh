#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (Apple Silicon only) Pull MLX local-LLM model weights into the shared
#   Hugging Face cache for use with mlx_lm.server (see 35-mlx.sh).
#
#   Opt-in only - model weights are large (GBs), so this is skipped unless
#   requested. Choose one:
#     DOTS_MLX_PULL=1 ./install mlx-models           # pull the default model
#     DOTS_MLX_MODELS="repo/id repo/id" ./install mlx-models   # pull specific
#
#   Recommended models for this machine (M1 Max, 64GB):
#     mlx-community/Qwen2.5-Coder-7B-Instruct-4bit     (~4GB,  fast)
#     mlx-community/Qwen3-Coder-30B-A3B-Instruct-4bit  (~17GB, primary) [default]
#     mlx-community/Qwen3-Coder-30B-A3B-Instruct-8bit  (~33GB, quality)
#     mlx-community/Qwen2.5-Coder-32B-Instruct-4bit    (~18GB, dense alt)
#

# Default model pulled when DOTS_MLX_PULL is set without an explicit list
DOTS_MLX_DEFAULT_MODEL="mlx-community/Qwen3-Coder-30B-A3B-Instruct-4bit"

# macOS only
[[ "$DOTS_OS" != "macos" ]] && { log_skip "Not macOS"; return 0; }

# Apple Silicon only (MLX requires a Metal GPU on arm64)
if [[ "$(uname -m)" != "arm64" ]]; then
    log_skip "Not Apple Silicon"
    return 0
fi

# Skip in Codespaces (no local GPU / not the target environment)
[[ "$DOTS_ENV" == "codespaces" ]] && { log_skip "Codespaces"; return 0; }

# Resolve which models to pull (explicit list wins, else default if opted in)
typeset -a MLX_MODELS=()
if [[ -n "$DOTS_MLX_MODELS" ]]; then
    read -ra MLX_MODELS <<< "$DOTS_MLX_MODELS"
elif [[ -n "$DOTS_MLX_PULL" ]]; then
    MLX_MODELS=("$DOTS_MLX_DEFAULT_MODEL")
fi

# Opt-in: nothing to do unless requested (weights are large)
if [[ ${#MLX_MODELS[@]} -eq 0 ]]; then
    log_skip "Set DOTS_MLX_PULL=1 or DOTS_MLX_MODELS to pull weights"
    return 0
fi

# Downloader uses the mise-provisioned uv (hf CLI via an ephemeral uvx env);
# weights land in the shared HF cache that mlx_lm.server reads.
if ! command -v uvx &>/dev/null; then
    log_warn "Skipping model pull: uvx not found (run 35-mlx first)"
    return 0
fi

hf_cache="${HF_HOME:-$HOME/.cache/huggingface}/hub"
for model in "${MLX_MODELS[@]}"; do
    cache_dir="$hf_cache/models--${model//\//--}"
    if [[ -d "$cache_dir" ]]; then
        log_skip "Already cached: $model"
        continue
    fi
    log_info "Pulling $model..."
    uvx --from huggingface_hub hf download "$model" 2>&1 | log_quote
done

log_pass "MLX models ready"
for model in "${MLX_MODELS[@]}"; do
    echo "$model" | log_quote
done
