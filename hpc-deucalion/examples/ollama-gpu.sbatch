#!/usr/bin/env bash
#SBATCH --job-name=aegis-ollama
#SBATCH --account=<DEUCALION_ACCOUNT>
#SBATCH --partition=<DEUCALION_PARTITION_GPU>
#SBATCH --qos=<DEUCALION_QOS>
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --gres=gpu:1
#SBATCH --time=04:00:00
#SBATCH --output=slurm-ollama-%j.out
#SBATCH --error=slurm-ollama-%j.err
#SBATCH --chdir=$WORK/aegis-kg
#SBATCH --exclusive

# ============================================================================
# ollama-gpu.sbatch — Start Ollama with one GPU on a compute node. Pre-pulls
# the model from the project config (or env), then sleeps to hold the job.
#
# Submit:
#   JID=$(sbatch --parsable ollama-gpu.sbatch)
# ============================================================================

set -euo pipefail
umask 077

export DEUCALION_PYTHON_MODULE="<DEUCALION_PYTHON_MODULE>"
export DEUCALION_CUDA_MODULE="<DEUCALION_CUDA_MODULE>"
source "$(dirname "${BASH_SOURCE[0]}")/env-setup.sh"

# --- Model cache on scratch (large, ephemeral) ---
OLLAMA_MODELS_DIR="$SCRATCH/ollama-models-${SLURM_JOB_ID}"
mkdir -p "$OLLAMA_MODELS_DIR"
export OLLAMA_MODELS="$OLLAMA_MODELS_DIR"

# --- Which model to pre-load? Default from env, else ask the user ---
: "${OLLAMA_MODEL:=llama3.1:8b}"
export OLLAMA_MODEL

echo "[ollama] starting on $(hostname), model=$OLLAMA_MODEL, models=$OLLAMA_MODELS_DIR"

# --- Sanity check the GPU ---
if ! command -v nvidia-smi >/dev/null 2>&1; then
  echo "[ollama] FATAL: nvidia-smi not found" >&2
  exit 1
fi
nvidia-smi | head -20

# --- Start ollama serve in the background ---
if ! command -v ollama >/dev/null 2>&1; then
  echo "[ollama] FATAL: ollama binary not found on PATH" >&2
  exit 1
fi

ollama serve > "$OLLAMA_MODELS_DIR/ollama.log" 2>&1 &
OLLAMA_PID=$!
trap 'echo "[ollama] stopping (pid=$OLLAMA_PID)"; kill $OLLAMA_PID 2>/dev/null || true; wait $OLLAMA_PID 2>/dev/null || true' SIGTERM SIGINT EXIT

# --- Wait for HTTP 11434 ---
for i in {1..30}; do
  if curl -sf http://localhost:11434/ >/dev/null 2>&1; then
    echo "[ollama] HTTP ready after ${i} attempts"
    break
  fi
  sleep 2
done
if ! curl -sf http://localhost:11434/ >/dev/null 2>&1; then
  echo "[ollama] FATAL: HTTP not ready after 60s" >&2
  cat "$OLLAMA_MODELS_DIR/ollama.log" >&2
  exit 1
fi

# --- Pre-pull model (fails loud if no internet inside job) ---
echo "[ollama] pulling $OLLAMA_MODEL (may take minutes)..."
if ! ollama pull "$OLLAMA_MODEL" 2>&1 | tail -20; then
  echo "[ollama] WARN: pull failed — model may not be available" >&2
fi

ollama list
touch "$OLLAMA_MODELS_DIR/READY"
echo "[ollama] service is up at http://$(hostname):11434 (model=$OLLAMA_MODEL)"

# --- Hold the job for the full walltime ---
sleep "$SLURM_JOB_TIME_LIMIT"
echo "[ollama] job ended"
