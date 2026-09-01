#!/usr/bin/env bash
#SBATCH --job-name=aegis-eval
#SBATCH --account=<DEUCALION_ACCOUNT>
#SBATCH --partition=<DEUCALION_PARTITION>
#SBATCH --qos=<DEUCALION_QOS>
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=02:00:00
#SBATCH --output=slurm-eval-%j.out
#SBATCH --error=slurm-eval-%j.err
#SBATCH --chdir=$WORK/aegis-kg

# ============================================================================
# eval-batch.sbatch — Run one or more eval tasks with the AEGIS-KG runner.
# Starts Neo4j + (optionally) Ollama inside the same job (pattern A).
#
# Always start with 1 task and 1 trial as a smoke test. Then scale up.
#
# Required env vars (set in ~/.aegis_env or export before sbatch):
#   EVAL_CASE    e.g. cases/case1-aegis-tinytask
#   EVAL_TASKS   e.g. T001                  (single task)
#           or   e.g. T001,T002,T003        (CSV, run serially)
#   EVAL_TRIALS  e.g. 1                     (start with 1)
#
# Submit:
#   EVAL_TASKS=T001 EVAL_TRIALS=1 EVAL_CASE=cases/case1-aegis-tinytask \
#     sbatch eval-batch.sbatch
# ============================================================================

set -euo pipefail
umask 077

export DEUCALION_PYTHON_MODULE="<DEUCALION_PYTHON_MODULE>"
source "$(dirname "${BASH_SOURCE[0]}")/env-setup.sh"

# --- Defaults / validation ---
: "${EVAL_CASE:=cases/case1-aegis-tinytask}"
: "${EVAL_TASKS:=T001}"
: "${EVAL_TRIALS:=1}"
: "${EVAL_RESULTS_DIR:=$WORK/aegis-kg/results/eval-${SLURM_JOB_ID}}"
export EVAL_CASE EVAL_TASKS EVAL_TRIALS EVAL_RESULTS_DIR
mkdir -p "$EVAL_RESULTS_DIR"

echo "[eval] case=$EVAL_CASE tasks=$EVAL_TASKS trials=$EVAL_TRIALS"
echo "[eval] results -> $EVAL_RESULTS_DIR"

# --- Start Neo4j on this node ---
NEO4J_HTTP_PORT=7475
NEO4J_BOLT_PORT=7688
NEO4J_DATA_DIR="$SCRATCH/neo4j-data-${SLURM_JOB_ID}"
mkdir -p "$NEO4J_DATA_DIR"
export NEO4J_DATA_DIR

if ! command -v neo4j >/dev/null 2>&1; then
  echo "[eval] FATAL: neo4j not on PATH" >&2
  exit 1
fi
neo4j start > "$NEO4J_DATA_DIR/start.log" 2>&1
for i in {1..30}; do
  curl -sf "http://localhost:${NEO4J_HTTP_PORT}/" >/dev/null 2>&1 && break
  sleep 2
done
curl -sf "http://localhost:${NEO4J_HTTP_PORT}/" >/dev/null 2>&1 \
  || { echo "[eval] FATAL: neo4j not ready"; cat "$NEO4J_DATA_DIR/start.log" >&2; neo4j stop || true; exit 1; }

# --- (Optional) start Ollama if requested ---
START_OLLAMA="${START_OLLAMA:-false}"
if [[ "$START_OLLAMA" == "true" ]]; then
  OLLAMA_MODELS_DIR="$SCRATCH/ollama-models-${SLURM_JOB_ID}"
  mkdir -p "$OLLAMA_MODELS_DIR"
  export OLLAMA_MODELS="$OLLAMA_MODELS_DIR"
  export OLLAMA_HOST="http://localhost:11434"

  ollama serve > "$OLLAMA_MODELS_DIR/ollama.log" 2>&1 &
  OLLAMA_PID=$!
  for i in {1..30}; do
    curl -sf http://localhost:11434/ >/dev/null 2>&1 && break
    sleep 2
  done
  curl -sf http://localhost:11434/ >/dev/null 2>&1 \
    || { echo "[eval] FATAL: ollama not ready"; kill $OLLAMA_PID 2>/dev/null || true; exit 1; }

  if [[ -n "${OLLAMA_MODEL:-}" ]]; then
    ollama pull "$OLLAMA_MODEL" 2>&1 | tail -5
  fi
fi

# --- Teardown on exit ---
cleanup() {
  echo "[eval] cleanup"
  if [[ -n "${OLLAMA_PID:-}" ]]; then kill "$OLLAMA_PID" 2>/dev/null || true; fi
  neo4j stop || true
  # Persist results to $WORK before scratch purge
  if [[ -d "$EVAL_RESULTS_DIR" ]]; then
    rsync -a "$EVAL_RESULTS_DIR/" "$WORK/aegis-kg/results/${SLURM_JOB_ID}/" 2>/dev/null || true
  fi
}
trap cleanup EXIT

# --- Run the eval ---
IFS=',' read -ra TASKS <<< "$EVAL_TASKS"
for TASK in "${TASKS[@]}"; do
  TASK=$(echo "$TASK" | xargs)  # trim
  echo "[eval] >>> running $TASK (trials=$EVAL_TRIALS)"
  python -m core.eval.run_eval \
    --case "$EVAL_CASE" \
    --task "$TASK" \
    --trials "$EVAL_TRIALS" \
    --output-dir "$EVAL_RESULTS_DIR/$TASK" \
    --verbose
done

echo "[eval] DONE"
