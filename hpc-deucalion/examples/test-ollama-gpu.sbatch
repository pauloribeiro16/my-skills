#!/usr/bin/env bash
#SBATCH --job-name=aegis-ollama-gpu
#SBATCH --account=<DEUCALION_ACCOUNT>
#SBATCH --partition=<DEUCALION_PARTITION_GPU>
#SBATCH --qos=<DEUCALION_QOS>
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --gres=gpu:1
#SBATCH --time=02:00:00
#SBATCH --output=slurm-ollama-gpu-%j.out
#SBATCH --error=slurm-ollama-gpu-%j.err
#SBATCH --chdir=$WORK/aegis-kg

# ============================================================================
# test-ollama-gpu.sbatch — Real AEGIS-KG run on a Deucalion GPU node.
#
# Pipeline:
#   1. Load Python + CUDA modules
#   2. Activate venv
#   3. Source ~/.aegis_env (Langfuse Cloud keys, etc.)
#   4. Start Ollama in background, pull model
#   5. Run direct LLM smoke test
#   6. Run full agent test (no Neo4j — agent runs in degraded mode)
#   7. Persist results to $WORK, kill Ollama
#
# Required:
#   - ~/.aegis_env with NEO4J_PASSWORD, LANGFUSE_* vars
#   - case.yaml with ollama.model
#   - account/partition with GPU access
#
# Submit:
#   sbatch .opencode/skills/hpc-deucalion/examples/test-ollama-gpu.sbatch
# ============================================================================

set -euo pipefail
umask 077

# --- Site-specific modules ---
export DEUCALION_PYTHON_MODULE="<DEUCALION_PYTHON_MODULE>"
export DEUCALION_CUDA_MODULE="<DEUCALION_CUDA_MODULE>"
source "$(dirname "${BASH_SOURCE[0]}")/env-setup.sh"

# --- Per-job scratch dirs ---
SCRATCH_JOB="$SCRATCH/aegis-job-${SLURM_JOB_ID}"
OLLAMA_MODELS_DIR="$SCRATCH_JOB/ollama-models"
RESULTS_DIR="$WORK/aegis-kg/results/ollama-gpu-${SLURM_JOB_ID}"
mkdir -p "$SCRATCH_JOB" "$OLLAMA_MODELS_DIR" "$RESULTS_DIR"
export OLLAMA_MODELS="$OLLAMA_MODELS_DIR"
export OLLAMA_HOST="http://localhost:11434"

# --- Get the model from case.yaml ---
MODEL=$(python -c "
import yaml
with open('cases/case1-aegis-tinytask/case.yaml') as f:
    c = yaml.safe_load(f)
print(c.get('ollama', {}).get('model', 'llama3.1:8b'))
")
echo "[ollama-gpu] model from case.yaml: $MODEL"

# --- Load aegis_env (secrets) ---
if [[ -f "$HOME/.aegis_env" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$HOME/.aegis_env"
  set +a
  echo "[ollama-gpu] sourced ~/.aegis_env"
else
  echo "[ollama-gpu] WARN: ~/.aegis_env not found, using shell env only" >&2
fi

# --- Verify GPU ---
echo "[ollama-gpu] GPU on $(hostname):"
nvidia-smi 2>&1 | head -10 || { echo "[ollama-gpu] FATAL: no GPU"; exit 1; }

# --- Start Ollama ---
echo "[ollama-gpu] starting ollama serve"
ollama serve > "$SCRATCH_JOB/ollama.log" 2>&1 &
OLLAMA_PID=$!

cleanup() {
  echo "[ollama-gpu] cleanup"
  if [[ -n "${OLLAMA_PID:-}" ]]; then
    kill "$OLLAMA_PID" 2>/dev/null || true
    wait "$OLLAMA_PID" 2>/dev/null || true
  fi
  echo "[ollama-gpu] results: $RESULTS_DIR"
  rsync -a "$RESULTS_DIR/" "$WORK/aegis-kg/results/${SLURM_JOB_ID}/" 2>/dev/null || true
}
trap cleanup EXIT SIGTERM SIGINT

for i in {1..30}; do
  if curl -sf http://localhost:11434/ >/dev/null 2>&1; then
    echo "[ollama-gpu] ollama ready after ${i} attempts"
    break
  fi
  sleep 2
done
curl -sf http://localhost:11434/ >/dev/null 2>&1 \
  || { echo "[ollama-gpu] FATAL: ollama not ready"; cat "$SCRATCH_JOB/ollama.log" >&2; exit 1; }

# --- Pull model ---
echo "[ollama-gpu] pulling model $MODEL (this can take minutes)"
ollama pull "$MODEL" 2>&1 | tail -20

# --- Test 1: direct LLM call ---
echo ""
echo "=== TEST 1: Direct LLM call (no agent, no Neo4j) ==="
python <<EOF
import json
from core.agent.llm.ollama import OllamaClient
client = OllamaClient(config={"model": "$MODEL", "base_url": "http://localhost:11434"})
result = client.generate(
    prompt="Write a Cypher query to count all clauses of the GDPR regulation.",
    system="You are a Neo4j Cypher expert. Output only the query.",
    task_name="scout_llm_test",
)
print("LLM output (first 500 chars):")
print(result["raw"][:500])
print("TEST 1: OK")
EOF

# --- Test 2: full agent (no Neo4j — will degrade gracefully) ---
echo ""
echo "=== TEST 2: Full agent (no Neo4j, Langfuse=$LANGFUSE_ENABLED) ==="
USE_TRACING="false"
if [[ "${LANGFUSE_ENABLED:-false}" == "true" ]]; then
  USE_TRACING="true"
fi
python <<EOF
import json
from core.agent.agent import AegisAgent
agent = AegisAgent(
    case_path="cases/case1-aegis-tinytask",
    use_tracing=$USE_TRACING,
    verbose=True,
)
result = agent.run("How many clauses does GDPR have?")
out = {
    "success": result.get("success"),
    "cypher": (result.get("cypher") or "")[:500],
    "answer": (result.get("answer") or "")[:500],
    "steps": len(result.get("steps", [])),
}
with open("$RESULTS_DIR/agent_test.json", "w") as f:
    json.dump(out, f, indent=2)
print(json.dumps(out, indent=2))
print("TEST 2: OK (results in $RESULTS_DIR/agent_test.json)")
EOF

# --- Test 3: a few more questions (show variety) ---
echo ""
echo "=== TEST 3: Multiple questions (no Neo4j) ==="
python <<EOF
import json
from core.agent.agent import AegisAgent
agent = AegisAgent(case_path="cases/case1-aegis-tinytask", use_tracing=$USE_TRACING, verbose=False)
questions = [
    "List the regulations tracked in the knowledge graph.",
    "Which clauses are in the NIS2 regulation?",
    "What obligations does GDPR impose?",
]
results = []
for q in questions:
    r = agent.run(q)
    results.append({
        "q": q,
        "success": r.get("success"),
        "cypher_len": len(r.get("cypher") or ""),
        "answer_len": len(r.get("answer") or ""),
    })
with open("$RESULTS_DIR/multi_test.json", "w") as f:
    json.dump(results, f, indent=2)
for r in results:
    print(f"  Q: {r['q'][:60]}")
    print(f"     success={r['success']}  cypher_len={r['cypher_len']}  answer_len={r['answer_len']}")
print("TEST 3: OK")
EOF

echo ""
echo "=== ALL TESTS DONE ==="
echo "Results: $RESULTS_DIR"
ls -la "$RESULTS_DIR"
