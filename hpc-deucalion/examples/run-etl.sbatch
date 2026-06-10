#!/usr/bin/env bash
#SBATCH --job-name=aegis-etl
#SBATCH --account=<DEUCALION_ACCOUNT>
#SBATCH --partition=<DEUCALION_PARTITION>
#SBATCH --qos=<DEUCALION_QOS>
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --output=slurm-etl-%j.out
#SBATCH --error=slurm-etl-%j.err
#SBATCH --chdir=$WORK/aegis-kg

# ============================================================================
# run-etl.sbatch — Run the ETL pipeline for one case. Starts Neo4j inside the
# job, runs the requested phases in order, and tears down on exit.
#
# Required env vars:
#   ETL_CASE   e.g. cases/case1-aegis-tinytask
#   ETL_PHASE  one of: 1, 2, 3, all   (default: all)
#
# Submit:
#   ETL_CASE=cases/case1-aegis-tinytask ETL_PHASE=all \
#     sbatch run-etl.sbatch
# ============================================================================

set -euo pipefail
umask 077

export DEUCALION_PYTHON_MODULE="<DEUCALION_PYTHON_MODULE>"
source "$(dirname "${BASH_SOURCE[0]}")/env-setup.sh"

: "${ETL_CASE:=cases/case1-aegis-tinytask}"
: "${ETL_PHASE:=all}"
: "${ETL_RESULTS_DIR:=$WORK/aegis-kg/results/etl-${SLURM_JOB_ID}}"
export ETL_CASE ETL_PHASE ETL_RESULTS_DIR
mkdir -p "$ETL_RESULTS_DIR"

echo "[etl] case=$ETL_CASE phase=$ETL_PHASE"
echo "[etl] results -> $ETL_RESULTS_DIR"

# --- Start Neo4j ---
NEO4J_HTTP_PORT=7475
NEO4J_BOLT_PORT=7688
NEO4J_DATA_DIR="$SCRATCH/neo4j-data-${SLURM_JOB_ID}"
mkdir -p "$NEO4J_DATA_DIR"
export NEO4J_DATA_DIR

neo4j start > "$NEO4J_DATA_DIR/start.log" 2>&1
for i in {1..30}; do
  curl -sf "http://localhost:${NEO4J_HTTP_PORT}/" >/dev/null 2>&1 && break
  sleep 2
done
curl -sf "http://localhost:${NEO4J_HTTP_PORT}/" >/dev/null 2>&1 \
  || { echo "[etl] FATAL: neo4j not ready"; cat "$NEO4J_DATA_DIR/start.log" >&2; neo4j stop || true; exit 1; }

cleanup() {
  echo "[etl] cleanup"
  neo4j stop || true
  rsync -a "$ETL_RESULTS_DIR/" "$WORK/aegis-kg/results/${SLURM_JOB_ID}/" 2>/dev/null || true
}
trap cleanup EXIT

# --- Run the phases ---
run_phase() {
  local PHASE=$1
  echo "[etl] >>> phase $PHASE"
  case "$PHASE" in
    1)
      python -m "${ETL_CASE}/etl/phase1/01_load_regulation_properties"
      ;;
    2)
      python -m "${ETL_CASE}/etl/phase2/parse_inputs"
      ;;
    3)
      python -m "${ETL_CASE}/etl/phase3/p3_01_load_data"
      ;;
    *)
      echo "[etl] unknown phase: $PHASE" >&2
      exit 2
      ;;
  esac
}

# NOTE: adjust the phase entry points to match the actual script names in
# the case's etl/ directory. Inspect:
#   ls -1 ${ETL_CASE}/etl/phase1/
#   ls -1 ${ETL_CASE}/etl/phase2/
#   ls -1 ${ETL_CASE}/etl/phase3/

case "$ETL_PHASE" in
  all)
    run_phase 1
    run_phase 2
    run_phase 3
    ;;
  1|2|3)
    run_phase "$ETL_PHASE"
    ;;
  *)
    echo "[etl] FATAL: ETL_PHASE must be 1, 2, 3, or all" >&2
    exit 2
    ;;
esac

echo "[etl] DONE"
