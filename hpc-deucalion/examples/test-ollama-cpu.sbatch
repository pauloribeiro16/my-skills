#!/usr/bin/env bash
#SBATCH --job-name=aegis-ollama-cpu
#SBATCH --account=<DEUCALION_ACCOUNT>
#SBATCH --partition=<DEUCALION_PARTITION>
#SBATCH --qos=<DEUCALION_QOS>
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --output=slurm-ollama-cpu-%j.out
#SBATCH --error=slurm-ollama-cpu-%j.err
#SBATCH --chdir=$WORK/aegis-kg

# ============================================================================
# test-ollama-cpu.sbatch — CPU-only fallback when no GPU is available.
#
# Use this when:
#   - GPU partition is busy for >24h
#   - You don't have GPU access
#   - You want to validate the pipeline end-to-end before "wasting" GPU hours
#
# WARNING: CPU inference is 10-60x slower than GPU. A single question may
# take 30s-2min instead of 1-5s. Use a small model (e.g., gemma:2b or
# llama3.2:3b) and few questions.
#
# Submit:
#   sbatch .opencode/skills/hpc-deucalion/examples/test-ollama-cpu.sbatch
# ============================================================================

set -euo pipefail
umask 077

export DEUCALION_PYTHON_MODULE="<DEUCALION_PYTHON_MODULE>"
source "$(dirname "${BASH_SOURCE[0]}")/env-setup.sh"

SCRATCH_JOB="$SCRATCH/aegis-cpu-${SLURM_JOB_ID}"
OLLAMA_MODELS_DIR="$SCRATCH_JOB/ollama-models"
RESULTS_DIR="$WORK/aegis-kg/results/ollama-cpu-${SLURM_JOB_ID}"
mkdir -p "$SCRATCH_JOB" "$OLLAMA_MODELS_DIR" "$RESULTS_DIR"
export OLLAMA_MODELS="$OLLAMA_MODELS_DIR"
export OLLAMA_HOST="http://localhost:11434"
# Reduce context to save memory
export OLLAMA_NUM_CTX="1024"

# CPU-friendly model (override via env if needed)
: "${OLLAMA_CPU_MODEL:=llama3.2:3b}"
MODEL="$OLLAMA_CPU_MODEL"
echo "[ollama-cpu] using model: $MODEL"

if [[ -f "$HOME/.aegis_env" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$HOME/.aegis_env"
  set +a
fi

USE_TRACING="false"
if [[ "${LANGFUSE_ENABLED:-false}" == "true" ]]; then
  USE_TRACING="true"
fi

# --- Start Ollama (CPU mode) ---
echo "[ollama-cpu] starting ollama serve (CPU)"
ollama serve > "$SCRATCH_JOB/ollama.log" 2>&1 &
OLLAMA_PID=$!

cleanup() {
  echo "[ollama-cpu] cleanup"
  [[ -n "${OLLAMA_PID:-}" ]] && kill "$OLLAMA_PID" 2>/dev/null || true
  wait "$OLLAMA_PID" 2>/dev/null || true
  rsync -a "$RESULTS_DIR/" "$WORK/aegis-kg/results/${SLURM_JOB_ID}/" 2>/dev/null || true
}
trap cleanup EXIT SIGTERM SIGINT

for i in {1..30}; do
  curl -sf http://localhost:11434/ >/dev/null 2>&1 && break
  sleep 2
done
curl -sf http://localhost:11434/ >/dev/null 2>&1 \
  || { echo "[ollama-cpu] FATAL: ollama not ready"; cat "$SCRATCH_JOB/ollama.log" >&2; exit 1; }

# --- Pull model ---
echo "[ollama-cpu] pulling $MODEL"
ollama pull "$MODEL" 2>&1 | tail -10

# --- Run a single test question (CPU is slow, keep it short) ---
echo ""
echo "=== TEST: Single question on CPU ==="
START=$(date +%s)
python <<EOF
import json, time
from core.agent.agent import AegisAgent
t0 = time.time()
agent = AegisAgent(case_path="cases/case1-aegis-tinytask", use_tracing=$USE_TRACING, verbose=True)
result = agent.run("How many clauses does GDPR have?")
t1 = time.time()
out = {
    "elapsed_s": round(t1 - t0, 1),
    "success": result.get("success"),
    "cypher": (result.get("cypher") or "")[:500],
    "answer": (result.get("answer") or "")[:500],
    "steps": len(result.get("steps", [])),
}
with open("$RESULTS_DIR/cpu_test.json", "w") as f:
    json.dump(out, f, indent=2)
print(json.dumps(out, indent=2))
EOF
END=$(date +%s)
echo "[ollama-cpu] total walltime: $((END - START))s"

echo ""
echo "=== CPU TEST DONE ==="
echo "Results: $RESULTS_DIR"
ls -la "$RESULTS_DIR"
