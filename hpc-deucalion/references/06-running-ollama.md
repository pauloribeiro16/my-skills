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

## Pick the right GPU — sizing by parameters × quant × ctx

VRAM at inference ~ model weights + KV cache (ctx) + 1.5-2 GB of overhead
(Ollama runtime + activations). The cache partitioning in 0.32+ lets the
weights sit on one GPU and KV spill to another, so 2× GPU on the **same
node** is the right way to split a model that overflows one card.

Concrete figures (Ollama default quant is Q4_K_M unless the tag says
otherwise; ctx defaults to 2048, scale linearly with context length):

| Model tag (params)  | Weights (Q4_K_M) | + KV @ 32k ctx | + headroom | Fits 1× A100-40GB? | Fits 1× A100-80GB? |
|---------------------|------------------|----------------|------------|--------------------|--------------------|
| ≤ 9B (`ornith:9b`, `phi4:14b`) | 6-10 GB | 0.5-1 GB | +2 GB | **yes** | yes (overkill) |
| 14-20B | 10-14 GB | 1-2 GB | +2 GB | **yes** | yes (overkill) |
| 27-30B (`qwen3.8:27b`, `granite4.2:30b`, `nemotron-3.5-lightning:30b`, `muse-glimmer:30b`) | 18-22 GB | 4-6 GB | +2 GB | **yes** | yes |
| 70B (`llama3:70b`-style) | 42-46 GB | 8-10 GB | +2 GB | no, ~64GB | **yes** (one card, 80GB) |
| > 80B weights | 60+ GB | scales | +2 GB | no | no — use `--gres=gpu:a100:2` on the same A100-80 node |

These are **fits-in-VRAM** estimates. Other bottlenecks (context-length
balloon at 65k+, OOM at intermediate layers) come up only at extreme
contexts that AEGIS doesn't use (≤ 32k). KV cache scaling: fp16 KV cache
≈ `2 × n_layers × n_kv_heads × head_dim × 2 bytes × seq_len` — for a
70B Q4 model with 32k ctx the KV cache is roughly 8-10 GB. If your
prompt+output is much larger, bump the estimated headroom by 10-20%.

**Decision tree before submitting `sbatch`:**

1. Total weights + KV ≤ 36 GB → try `dev-a100-40` first; fall back to
   `normal-a100-40`. Saves the 80GB queue for models that need it.
2. Total weights + KV 36-72 GB → `dev-a100-80`; fall back to
   `normal-a100-80`.
3. Total > 72 GB → `--gres=gpu:a100:2` on the same 80GB node (Ollama
   splits layers automatically; never cross-node). With ≥2× 40GB
   GPUs available AND the workload tolerates slower inference,
   `--gres=gpu:a100:2` on `dev-a100-40` also works (more queue slots).
4. Egress to `registry.ollama.ai` is blocked on compute nodes — if the
   model isn't in the local cache, schedule a
   `download-models.sbatch` on `normal-a100-40` first (see Recipe below).

**Parallel jobs (today's lesson, 2026-09-02):** multiple scouts on
**different nodes** run safely; multiple scouts on the same node
collide on port 11434 (Connection refused / Server disconnected). After
`SBATCH` shows your batch in `squeue`, **check `%.32R` (Reason column)
or `scontrol show job <id>` before assuming success** — a
`Nodes required for job are DOWN, DRAINED or reserved` reason means
SLURM is still schedulering and your parallel batch isn't actually
parallel yet.

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
