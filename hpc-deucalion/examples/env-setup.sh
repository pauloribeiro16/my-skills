#!/usr/bin/env bash
# env-setup.sh — Idempotent env + module loader for Deucalion login sessions.
# Source this from your login shell or from inside an sbatch script.
#
# Usage:
#   source env-setup.sh
#
# Required env vars (export before sourcing, or edit the placeholders):
#   DEUCALION_PYTHON_MODULE  e.g. python/3.11.5
#   DEUCALION_CUDA_MODULE    e.g. cuda/12.2   (optional, GPU only)
#   DEUCALION_OLLAMA_MODULE  e.g. ollama/0.3  (optional)
#   WORK                     e.g. /work/$USER
#
# This script is safe to source multiple times.

# Fail fast on unbound variables, but don't exit if sourcing from a non-bash shell
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "[env-setup] Please source this file, do not execute: source $0" >&2
  exit 1
fi

# --- 1. Modules ---
if command -v module >/dev/null 2>&1; then
  module purge
  if [[ -n "${DEUCALION_PYTHON_MODULE:-}" ]]; then
    module load "$DEUCALION_PYTHON_MODULE" || echo "[env-setup] WARN: failed to load $DEUCALION_PYTHON_MODULE" >&2
  else
    echo "[env-setup] WARN: DEUCALION_PYTHON_MODULE is not set" >&2
  fi
  if [[ -n "${DEUCALION_CUDA_MODULE:-}" ]] && [[ "${DEUCALION_CUDA_MODULE}" != "none" ]]; then
    module load "$DEUCALION_CUDA_MODULE" || echo "[env-setup] WARN: failed to load $DEUCALION_CUDA_MODULE" >&2
  fi
  if [[ -n "${DEUCALION_OLLAMA_MODULE:-}" ]] && [[ "${DEUCALION_OLLAMA_MODULE}" != "none" ]]; then
    module load "$DEUCALION_OLLAMA_MODULE" || echo "[env-setup] WARN: failed to load $DEUCALION_OLLAMA_MODULE" >&2
  fi
else
  echo "[env-setup] WARN: 'module' command not found — is this an HPC node?" >&2
fi

# --- 2. Storage locations ---
: "${WORK:=$HOME/work}"
: "${SCRATCH:=/scratch/$USER}"
export WORK SCRATCH

# --- 3. Project location ---
: "${AEGIS_KG_DIR:=$WORK/aegis-kg}"
export AEGIS_KG_DIR

# --- 4. Python venv ---
if [[ -d "$AEGIS_KG_DIR/.venv" ]]; then
  # shellcheck disable=SC1091
  source "$AEGIS_KG_DIR/.venv/bin/activate"
  export PYTHONPATH="$AEGIS_KG_DIR:${PYTHONPATH:-}"
  export PIP_CACHE_DIR="$AEGIS_KG_DIR/.pip-cache"
else
  echo "[env-setup] NOTE: venv not found at $AEGIS_KG_DIR/.venv — create with: python -m venv $AEGIS_KG_DIR/.venv" >&2
fi

# --- 5. AEGIS env file (secrets, service URLs) ---
if [[ -f "$HOME/.aegis_env" ]]; then
  # shellcheck disable=SC1090
  set -a
  source "$HOME/.aegis_env"
  set +a
fi

# --- 6. Langfuse default off ---
: "${LANGFUSE_ENABLED:=false}"
export LANGFUSE_ENABLED

# --- 7. Quick summary ---
echo "[env-setup] python: $(command -v python 2>/dev/null || echo 'not found')"
echo "[env-setup] AEGIS_KG_DIR=$AEGIS_KG_DIR"
echo "[env-setup] PYTHONPATH=$PYTHONPATH"
echo "[env-setup] LANGFUSE_ENABLED=$LANGFUSE_ENABLED"
