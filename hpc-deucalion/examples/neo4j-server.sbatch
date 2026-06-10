#!/usr/bin/env bash
#SBATCH --job-name=aegis-neo4j
#SBATCH --account=<DEUCALION_ACCOUNT>
#SBATCH --partition=<DEUCALION_PARTITION>
#SBATCH --qos=<DEUCALION_QOS>
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --output=slurm-neo4j-%j.out
#SBATCH --error=slurm-neo4j-%j.err
#SBATCH --chdir=$WORK/aegis-kg
#SBATCH --exclusive

# ============================================================================
# neo4j-server.sbatch — Start Neo4j on a compute node for the lifetime of the
# job. Pair with other jobs via --dependency, or use as a service for an
# array of worker jobs.
#
# Submit:
#   JID=$(sbatch --parsable neo4j-server.sbatch)
#   # Then:
#   squeue -j $JID -o "%N"  # discover the compute node hostname
# ============================================================================

set -euo pipefail
umask 077

# --- Site-specific modules ---
export DEUCALION_PYTHON_MODULE="<DEUCALION_PYTHON_MODULE>"
source "${AEGIS_KG_DIR:-$WORK/aegis-kg}/../env-setup.sh" 2>/dev/null \
  || source "$(dirname "${BASH_SOURCE[0]}")/env-setup.sh"

# --- Neo4j data dir on local-fast scratch ---
NEO4J_DATA_DIR="$SCRATCH/neo4j-data-${SLURM_JOB_ID}"
mkdir -p "$NEO4J_DATA_DIR"
export NEO4J_DATA_DIR

# --- Project port rule (HARD) ---
NEO4J_HTTP_PORT=7475
NEO4J_BOLT_PORT=7688

# --- Start Neo4j ---
# Assumes `neo4j` is on PATH (module load or venv). Adjust as needed.
if ! command -v neo4j >/dev/null 2>&1; then
  echo "[neo4j] FATAL: neo4j binary not found on PATH" >&2
  exit 1
fi

echo "[neo4j] starting in $NEO4J_DATA_DIR"
neo4j start > "$NEO4J_DATA_DIR/start.log" 2>&1

# --- Wait for HTTP to be ready (max 60s) ---
for i in {1..30}; do
  if curl -sf "http://localhost:${NEO4J_HTTP_PORT}/" >/dev/null 2>&1; then
    echo "[neo4j] ready after ${i} attempts"
    break
  fi
  sleep 2
done

if ! curl -sf "http://localhost:${NEO4J_HTTP_PORT}/" >/dev/null 2>&1; then
  echo "[neo4j] FATAL: not ready after 60s" >&2
  cat "$NEO4J_DATA_DIR/start.log" >&2
  neo4j stop || true
  exit 1
fi

# --- Hold the job open so the service stays alive ---
echo "[neo4j] service is up on $(hostname):${NEO4J_HTTP_PORT} (HTTP) / ${NEO4J_BOLT_PORT} (Bolt)"
echo "[neo4j] job will hold for ${SLURM_JOB_TIME_LIMIT}"

# Touch a sentinel so dependent jobs can wait on it
touch "$NEO4J_DATA_DIR/READY"

# Sleep for the full walltime, but respond to SIGTERM cleanly
trap 'echo "[neo4j] stopping"; neo4j stop || true; exit 0' SIGTERM SIGINT
sleep "$SLURM_JOB_TIME_LIMIT"

# --- Teardown ---
neo4j stop || true
echo "[neo4j] job ended"
