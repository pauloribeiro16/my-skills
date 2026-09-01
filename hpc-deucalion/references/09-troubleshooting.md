# 09 — Troubleshooting

## "Disk quota exceeded"

Symptoms: `cp` or `pip install` fails with `No space left on device` or
`Disk quota exceeded`.

Fix:

```bash
df -h /home /projects/F202512235CPCAA1 /tmp
myquota
# Find the culprit
du -sh $HOME/* 2>/dev/null | sort -h | tail
du -sh /projects/F202512235CPCAA1/* 2>/dev/null | sort -h | tail
# Clean up: venv rebuilds from requirements.txt, pip cache is rebuildable
rm -rf ~/aegis-kg/.venv ~/aegis-kg/.pip-cache
```

**Do not** delete anything you cannot rebuild. Move big files to a
larger tier first.

## No internet inside the job

Symptoms: `pip install` times out, `git clone` fails, `ollama pull`
hangs, `curl https://...` times out.

Causes:
1. Compute nodes have no external egress (most clusters).
2. The proxy env vars are not set inside the job.

Fix:

```bash
# 1. Find the cluster proxy (usually documented; common pattern)
env | grep -i proxy
# If unset, check /etc/profile.d/, or ask the cluster admins.

# 2. If there is a proxy, export it in the job script
export http_proxy=http://proxy.example.com:8080
export https_proxy=http://proxy.example.com:8080
export no_proxy=localhost,127.0.0.1,.cluster.local

# 3. For pip specifically
pip install --proxy $http_proxy ...

# 4. For git
git -c http.proxy=$http_proxy clone ...
```

If there is no proxy and no egress, you must pre-populate the pip
cache and model dir on the shared Lustre cache `/projects/F202512235CPCAA1/CyberMetric_Deucalion/ollama_data/models` (pre-loaded, see `06-running-ollama.md`).

## GPU out of memory

Symptoms: `CUDA OOM`, `RuntimeError: CUDA out of memory`,
`ollama serve` dies, `nvidia-smi` shows 0 MiB free.

Fix:

- Use a smaller quantized model: `q4_K_M` instead of `q8_0` or `f16`.
- Reduce context length: set `OLLAMA_NUM_CTX=2048` (or lower).
- Use a larger GPU partition if available.
- Reduce concurrent LLM calls (the eval runner may have a setting).
- **Don't** swap to CPU silently — surface the error to the user. They
  may want to change the model.

## `ollama serve` exits immediately

Check `/tmp/aegis-job-${SLURM_JOB_ID}/ollama.log`:

| Error in log | Cause | Fix |
|--------------|-------|-----|
| `bind: address already in use` | Port 11434 taken | Kill the other process, or use a different port + `OLLAMA_HOST` |
| `error while loading shared libraries: libcuda.so` | CUDA module not loaded | `module load cuda/...` matching the driver |
| `model not found` | `OLLAMA_MODELS` path wrong, or `ollama pull` not run | Verify `ollama list` shows the model |
| `permission denied` on `/tmp/aegis-job-${SLURM_JOB_ID}/ollama-models-...` | Directory not writable | `chmod 700` the dir |

## Neo4j not ready

Symptoms: `python ...` fails with `ServiceUnavailable: Couldn't connect
to localhost:7475` immediately.

Fix:

```bash
# Wait longer
for i in {1..60}; do
  curl -sf http://localhost:7475 >/dev/null && break
  sleep 2
done
# If still failing
journalctl -u neo4j 2>/dev/null || cat $NEO4J_HOME/logs/neo4j.log | tail -50
```

Common log messages:

| Message | Cause | Fix |
|---------|-------|-----|
| `port 7475 in use` | Another Neo4j instance on the same node | `pkill -f neo4j` and retry |
| `Could not find Java` | Java module not loaded | `module load java/...` (and re-load neo4j module) |
| `Insufficient memory` | Heap too large for `--mem` | Lower `dbms.memory.heap.max_size` |
| `store lock` | Previous Neo4j crashed | `rm $NEO4J_DATA_DIR/databases/*/store_lock` (only if no Neo4j is running) |

## Port collision across jobs

Two `sbatch` jobs on the same node both want 7475/7688 (or 11434).

Fix:
- Use `#SBATCH --exclusive` on service jobs.
- For eval jobs that share a node, ensure they all connect to the
  **same** Neo4j/Ollama (pattern B) or use unique ports (last resort).

## Job pending forever

`PENDING (Priority)` for hours. Likely reasons:

- Your account's allocation is exhausted (`sacctmgr show assoc user=$USER`).
- The partition is full; consider a different partition or QoS.
- The job requested more than the partition allows
  (`scontrol show partition`).

Fix: check `scontrol show job <JOBID> | grep -i reason` and act on the
specific reason.

## Walltime exceeded

The job was killed because it ran longer than `--time`. Either:
- Increase `--time` (and check the partition's max).
- Break the work into smaller jobs with checkpointing.
- Add progress logging so you can see what part was running.

## Module not found

`module load foo/1.2` → "foo/1.2 not found".

```bash
module avail foo        # exact list
module spider foo       # if module hierarchy is non-trivial
```

If still missing, the software is not installed. **Stop and ask the
user** — do not build from source unless the user agrees.

## `PYTHONPATH` not set in job

The root `AGENTS.md` says `export PYTHONPATH=.`. On HPC the job starts
in `--chdir`, so `PYTHONPATH=.` works **only if** `.` resolves to the
project root. Always:

```bash
export PYTHONPATH="$PWD:$PYTHONPATH"
```

or use `#SBATCH --chdir=/home/paulinho/aegis-kg`.

## SSH to compute node from laptop fails

The compute node is on a private network. Use the login node as a jump
host, or use the SSH tunnel pattern in `01-access.md`.

## `git push` from inside a job fails

The compute node may not have your SSH key, or the network is blocked.
Run `git push` from the login node (after the job ends) instead.
