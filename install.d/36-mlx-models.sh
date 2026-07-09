#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   (Apple Silicon only) Pull MLX local-LLM model weights into the shared
#   Hugging Face cache for use with mlx_lm.server (see 35-mlx.sh).
#
#   Opt-in only - model weights are large (GBs), so this is skipped unless
#   requested. Selection is driven by the shared inventory (stowed to
#   ~/.config/dev-model/inventory.tsv), the same list `dev-model` serves from:
#     DOTS_MLX_PULL=1        ./install mlx-models   # the default-tagged model
#     DOTS_MLX_PULL=all      ./install mlx-models   # the entire inventory
#     DOTS_MLX_TIER="s m"    ./install mlx-models   # everything in those tiers
#     DOTS_MLX_TAGS=agentic  ./install mlx-models   # everything with a tag
#     DOTS_MLX_MODELS="id …" ./install mlx-models   # explicit ids (wins)
#
#   Tiers gauge RAM: s <8GB, m ~15-25GB, l ~35-70GB, xl >100GB. `agentic` = has
#   a native mlx_lm tool-call parser (MCP/tool-use ready).
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

# Resolve which models to pull. Precedence: explicit list > all > tier/tags >
# default-tagged. Driven by the shared inventory (stowed by 23-stow.sh).
INV="${XDG_CONFIG_HOME:-$HOME/.config}/dev-model/inventory.tsv"
_inv_rows() { grep -v '^[[:space:]]*#' "$INV" 2>/dev/null | grep -v '^[[:space:]]*$'; }

typeset -a MLX_MODELS=()
if [[ -n "${DOTS_MLX_MODELS:-}" ]]; then
    read -ra MLX_MODELS <<< "$DOTS_MLX_MODELS"
elif [[ "${DOTS_MLX_PULL:-}" == "all" ]]; then
    while IFS='|' read -r id _rest; do [[ -n "$id" ]] && MLX_MODELS+=("$id"); done < <(_inv_rows)
elif [[ -n "${DOTS_MLX_TIER:-}" || -n "${DOTS_MLX_TAGS:-}" ]]; then
    while IFS='|' read -r id tier tags _rest; do
        for t in ${DOTS_MLX_TIER:-}; do [[ "$tier" == "$t" ]] && MLX_MODELS+=("$id"); done
        for g in ${DOTS_MLX_TAGS:-}; do [[ ",$tags," == *",$g,"* ]] && MLX_MODELS+=("$id"); done
    done < <(_inv_rows)
elif [[ -n "${DOTS_MLX_PULL:-}" ]]; then
    while IFS='|' read -r id _tier tags _rest; do
        [[ ",$tags," == *",default,"* ]] && MLX_MODELS+=("$id")
    done < <(_inv_rows)
    [[ ${#MLX_MODELS[@]} -eq 0 ]] && MLX_MODELS=("$DOTS_MLX_DEFAULT_MODEL")   # inventory missing
fi

# de-duplicate, preserving order
if [[ ${#MLX_MODELS[@]} -gt 0 ]]; then
    typeset -a _dedup=()
    while IFS= read -r m; do [[ -n "$m" ]] && _dedup+=("$m"); done \
        < <(printf '%s\n' "${MLX_MODELS[@]}" | awk '!seen[$0]++')
    MLX_MODELS=("${_dedup[@]}")
fi

# Opt-in: nothing to do unless requested (weights are large)
if [[ ${#MLX_MODELS[@]} -eq 0 ]]; then
    log_skip "No models selected — DOTS_MLX_PULL=1|all, DOTS_MLX_TIER=\"s m\", DOTS_MLX_TAGS=agentic, or DOTS_MLX_MODELS=\"id …\""
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
    HF_HUB_DISABLE_XET=1 uvx --from huggingface_hub hf download "$model" 2>&1 | log_quote
done

log_pass "MLX models ready"
for model in "${MLX_MODELS[@]}"; do
    echo "$model" | log_quote
done
