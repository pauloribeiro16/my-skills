#!/usr/bin/env bash
# ============================================================================
# aegis-common.sh — Shared sbatch preamble for AEGIS-KG / AEGIS-Phase1 jobs.
#
# Source this from every `sbatch/aegis_*.sh`. It centralises the env that
# bit real jobs on 2026-08-13 (jobs 1819611-1819613) so that one edit
# fixes all scripts.
#
# Usage:
#   source "$(dirname "${BASH_SOURCE[0]}")/aegis-common.sh"
#
# What it sets (every line is a real lesson-learned):
#   - CUDA_HOME, DS_BUILD_OPS, DS_BUILD_AIO   → deepspeed imports cleanly
#                                                 (no nvcc on cluster)
#   - HF_HUB_OFFLINE, TRANSFORMERS_OFFLINE     → no spurious network calls
#   - LANGFUSE_ENABLED=false (default)         → opt-in only
#   - CACHE_ROOT under /projects/...           → $HOME quota is tiny
#   - TRITON / TORCHINDUCTOR / XDG / HF_HUB /
#     TRANSFORMERS / TORCH / TMPDIR redirects
#   - NCCL nccl-net / NCCL_IB_HCA             → reliable RDMA on a100
#   - gpus_safe helper                         → validated nproc_per_node
#   - max_new_tokens_safe                      → 16384 default ceiling
#
# Override anything by exporting the variable BEFORE sourcing this file.
# ============================================================================

set -euo pipefail

# --- Site paths ---------------------------------------------------------------
: "${DEUCALION_PROJECTS:=/projects/F202512235CPCAA1}"
: "${AEGIS_REPO_ROOT:=$DEUCALION_PROJECTS/CyberMetric_Deucalion}"
: "${AEGIS_CACHE_ROOT:=$AEGIS_REPO_ROOT/.cache}"

# --- CUDA / DeepSpeed / Transformers -----------------------------------------
# Deucalion has no nvcc on PATH. CUDA_HOME must be set (even if the dir
# doesn't fully exist) so deepspeed's optional op builds are skipped.
export CUDA_HOME="${CUDA_HOME:-/usr/local/cuda}"
export DS_BUILD_OPS="${DS_BUILD_OPS:-0}"
export DS_BUILD_AIO="${DS_BUILD_AIO:-0}"

# Avoid network calls during transformers/torch hub.
export HF_HUB_OFFLINE="${HF_HUB_OFFLINE:-1}"
export TRANSFORMERS_OFFLINE="${TRANSFORMERS_OFFLINE:-1}"
export HF_HOME="${HF_HOME:-$AEGIS_REPO_ROOT/models/hf/.cache}"

# Langfuse is opt-in. Default off for HPC cost reasons.
export LANGFUSE_ENABLED="${LANGFUSE_ENABLED:-false}"

# --- PYTHONPATH --------------------------------------------------------------
# Caller is expected to `cd` into the project root before sourcing, so
# `$PWD` resolves correctly. Add the repo and the `src` directory.
export PYTHONPATH="$AEGIS_REPO_ROOT:${PYTHONPATH:-}"

# --- Cache redirects (HOME quota is ~5 GB, /projects is Lustre) --------------
# Always export the cache env vars so downstream tools see consistent
# paths. Only create the directories when the project root exists and
# is writable (e.g. on the cluster, but not on a local workstation).
export TRITON_CACHE_DIR="${TRITON_CACHE_DIR:-$AEGIS_CACHE_ROOT/triton}"
export TORCHINDUCTOR_CACHE_DIR="${TORCHINDUCTOR_CACHE_DIR:-$AEGIS_CACHE_ROOT/inductor}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$AEGIS_CACHE_ROOT/xdg}"
export HF_HUB_CACHE="${HF_HUB_CACHE:-$AEGIS_CACHE_ROOT/hub}"
export TRANSFORMERS_CACHE="${TRANSFORMERS_CACHE:-$AEGIS_CACHE_ROOT/transformers}"
export TORCH_HOME="${TORCH_HOME:-$AEGIS_CACHE_ROOT/torch}"
export TMPDIR="${TMPDIR:-$AEGIS_CACHE_ROOT/tmp}"
if [[ -d "$AEGIS_REPO_ROOT" && -w "$AEGIS_REPO_ROOT" ]]; then
  mkdir -p "$AEGIS_CACHE_ROOT" \
    "$TRITON_CACHE_DIR" "$TORCHINDUCTOR_CACHE_DIR" "$XDG_CACHE_HOME" \
    "$HF_HUB_CACHE" "$TRANSFORMERS_CACHE" "$TORCH_HOME" "$TMPDIR"
fi

# --- NCCL (multi-node deepspeed / torchrun) ----------------------------------
# Disable problematic verbs; prefer IB on a100 nodes.
export NCCL_IB_DISABLE="${NCCL_IB_DISABLE:-0}"
export NCCL_IB_HCA="${NCCL_IB_HCA:-^mlx5_1,mlx5_2}"
export NCCL_SOCKET_IFNAME="${NCCL_SOCKET_IFNAME:-ib0}"
# Set to WARN or INFO only when debugging; default is ERROR which is enough.
export NCCL_DEBUG="${NCCL_DEBUG:-ERROR}"

# --- Defaults that triggered OOM in 2026-08-13 --------------------------------
# 31B models with device_map=auto on 2x80GB cannot sustain 65k-token
# generations. Default to 16384 unless the caller overrides explicitly.
export AEGIS_MAX_NEW_TOKENS="${AEGIS_MAX_NEW_TOKENS:-16384}"

# --- Helpers -----------------------------------------------------------------

# gpus_safe — robust nproc_per_node deriver.
#   Usage: gpus_safe; nproc=$REPLY
# Always returns a positive integer; aborts otherwise.
gpus_safe() {
  local g
  g="${SLURM_GPUS_ON_NODE:-}"
  if [[ -z "$g" ]]; then
    g="$(nvidia-smi -L 2>/dev/null | wc -l)"
  fi
  g="${g:-2}"
  if ! [[ "$g" =~ ^[0-9]+$ ]] || [[ "$g" -lt 1 ]]; then
    echo "FATAL: gpus_safe could not determine a positive integer" >&2
    return 1
  fi
  REPLY="$g"
}

# require_python_module — fail fast with a clear message if a module is missing.
#   Usage: require_python_module torch
#          require_python_module aegis_phase1.v2.output.doc_04
require_python_module() {
  python -c "import importlib, sys; \
m = importlib.import_module('$1'); \
print('OK', sys.modules.get('$1', m).__name__)" \
    || { echo "FATAL: missing python module: $1" >&2; exit 1; }
}

# echo_status — uniform log prefix with iso timestamp + slurm job id.
echo_status() {
  printf '[%s] [job=%s] %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "${SLURM_JOB_ID:-local}" "$*"
}

# --- Smoke-test entry-point ---------------------------------------------------
# If `--aegis-common-selftest` is the first arg, run selftests and exit.
if [[ "${1:-}" == "--aegis-common-selftest" ]]; then
  echo_status "aegis-common.sh selftest"
  echo "  CUDA_HOME=$CUDA_HOME"
  echo "  DS_BUILD_OPS=$DS_BUILD_OPS  DS_BUILD_AIO=$DS_BUILD_AIO"
  echo "  HF_HUB_OFFLINE=$HF_HUB_OFFLINE  TRANSFORMERS_OFFLINE=$TRANSFORMERS_OFFLINE"
  echo "  LANGFUSE_ENABLED=$LANGFUSE_ENABLED"
  echo "  AEGIS_CACHE_ROOT=$AEGIS_CACHE_ROOT"
  echo "  AEGIS_MAX_NEW_TOKENS=$AEGIS_MAX_NEW_TOKENS"
  gpus_safe
  echo "  gpus_safe=$REPLY"
  if command -v python >/dev/null 2>&1; then
    python -c "import torch; print('  torch=', torch.__version__, 'cuda=', torch.cuda.is_available())" \
      || echo "  (torch not importable in this env)"
  else
    echo "  (python not on PATH; skip torch check)"
  fi
  exit 0
fi
