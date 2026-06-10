# 06 — Running Ollama on Deucalion

## CPU vs GPU

| Option | Pros | Cons |
|--------|------|------|
| **Ollama on a GPU node** | Fast inference, 10-100x speedup | Requires GPU partition, may have quota |
| **Ollama on a CPU node** | No GPU quota needed | Slow (10-60 s / query for small models) — viable only for tiny smoke tests |
| **Ollama via `srun` on a shared GPU** | Pays for GPU-seconds only | Models have to be pre-loaded; concurrent jobs compete for VRAM |
| **vLLM instead of Ollama** | Better batching and throughput | Different API; requires extra integration code |

**Default: Ollama on a GPU node, one model loaded per job.** Switch to
vLLM only if the user asks.

## GPU sanity check (inside the allocation)

```bash
srun --partition=dev-a100-40 --gres=gpu:1 --pty bash
nvidia-smi
# Look for: GPU name (A100-40GB), driver version, CUDA version
```

If `nvidia-smi` is missing, the node may not have the driver module
loaded. `module load cuda/...` before running.

## Ollama binary — pre-installed

Deucalion has Ollama pre-installed at:
```
/projects/F202512235CPCAA1/CyberMetric_Deucalion/bin/ollama
```

Library deps at:
```
/projects/F202512235CPCAA1/CyberMetric_Deucalion/lib/ollama/
```

To use in a job script (or login shell):
```bash
export PATH="/projects/F202512235CPCAA1/CyberMetric_Deucalion/bin:$PATH"
export LD_LIBRARY_PATH="/projects/F202512235CPCAA1/CyberMetric_Deucalion/lib/ollama:$LD_LIBRARY_PATH"
ollama --version
```

Alternative (module — if the binary path is unavailable):
```bash
module load ollama/0.20.3-GCCcore-14.2.0-CUDA-12.8.0
```

**Prefer the pre-installed binary** — it matches the pre-loaded model
cache and has been tested.

## Model cache — pre-loaded, persistent

Models live in the shared Lustre cache:
```
OLLAMA_MODELS=/projects/F202512235CPCAA1/CyberMetric_Deucalion/ollama_data/models
```

**Do NOT set `OLLAMA_MODELS` to a per-job scratch dir.** The cache is
shared across all jobs and is the only place models exist. To verify a
model is available:

```bash
ollama list
# Should show models like gemma3:27b, gemma4:26b, etc.
```

If the model you need is missing, see "Pre-pulling models" below.

## Pre-pulling models (separate job)

To add a new model to the shared cache, run `download-models.sbatch`
on a GPU node (has internet to `registry.ollama.ai`):

```bash
# On login node
sbatch ~/aegis-kg/.opencode/skills/hpc-deucalion/examples/download-models.sbatch
```

This is a 12h job on `normal-a100-40` that:
1. Starts Ollama
2. Pulls models listed in the script's `MODELS` array
3. Stores them in the shared cache
4. Logs progress to `output/ollama_download_<JOBID>.log`

Edit the `MODELS` array in the script to add new models. Job cost is
~5-15 min per model (size-dependent).

## NO `ollama pull` inside AEGIS-KG jobs

AEGIS-KG eval/ETL jobs must NOT call `ollama pull`:
- Compute node egress to `registry.ollama.ai` is unreliable.
- `ollama pull` would race against concurrent jobs on the same node.
- Models are already in the shared cache — `ollama list` is enough.

If a model is missing, **stop and ask the user** to add it via
`download-models.sbatch`.

## Starting Ollama inside the job

```bash
export PATH="/projects/F202512235CPCAA1/CyberMetric_Deucalion/bin:$PATH"
export LD_LIBRARY_PATH="/projects/F202512235CPCAA1/CyberMetric_Deucalion/lib/ollama:$LD_LIBRARY_PATH"
export OLLAMA_MODELS="/projects/F202512235CPCAA1/CyberMetric_Deucalion/ollama_data/models"
export OLLAMA_HOST="http://localhost:11434"

ollama serve > "$JOB_TMP/ollama.log" 2>&1 &
OLLAMA_PID=$!
trap "kill $OLLAMA_PID 2>/dev/null" EXIT

for i in {1..30}; do
  curl -sf http://localhost:11434/ >/dev/null 2>&1 && break
  sleep 2
done

ollama list | grep -q "$MODEL" || { echo "Model $MODEL not in cache"; exit 1; }
```

## Multiple jobs sharing a GPU

Ollama uses a single global server per node. If you start a second job
on the same node, it will collide on port 11434.

Options:
- Use `--gres=gpu:1` plus a job-level lock (the scheduler usually
  prevents two GPU jobs from landing on the same GPU).
- For more aggressive sharing, run **one** Ollama job as a service
  (pattern B in `05-running-neo4j.md`) and have many workloads connect
  to it.

## Calling Ollama from the project

The project's `core/agent/ollama_client.py` uses
`langchain_ollama.ChatOllama`. Configure via env vars (do not hardcode
hosts in the code):

```bash
export OLLAMA_HOST='http://localhost:11434'   # if same node
# or
export OLLAMA_HOST='http://<compute_node>:11434'   # if separate job
```

For multi-node, see `01-access.md` → "SSH tunnels".

## Stop conditions

- The job hits a GPU memory error → use a smaller model or a different
  one. **Stop and ask** the user before downgrading model choice — it
  changes eval results.
- `ollama serve` exits immediately → check `$JOB_TMP/ollama.log`, often
  a port conflict or missing CUDA module.
- Model not in cache → run `download-models.sbatch`, NOT `ollama pull`.
