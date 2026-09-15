# 10 — Pre-Flight Checklist (Read Before Every Job)

Print this and run it mentally before every `sbatch` submission. If any
item is "no" or "?", **stop and resolve it first**.

## Identity and access

- [ ] You are logged into the login node (`hostname` matches
  `login.deucalion.macc.fccn.pt` (or your login node).
- [ ] Your SLURM account is valid: `sacctmgr show assoc user=$USER` shows
      at least one row with `GrpTRES` (trackable resources).
- [ ] You have read permission on the project directory
      (`ls ~/aegis-kg`).

## Code and data

- [ ] The repo is at `~/aegis-kg` (NFS, not in HOME subdir, not in /tmp). Note: Deucalion does NOT export `$WORK`.
- [ ] You are on the right branch (`git status`, `git log -1`).
- [ ] `requirements.txt` is up to date with what the code expects.
- [ ] If ETL: input CSVs are present in `data/phase<N>/`.
- [ ] If eval: Neo4j is pre-loaded with the right case (otherwise
      pattern A — start Neo4j inside the job).

## Environment

- [ ] `module load Python/3.11.3-GCCcore-12.3.0` (3.11+) succeeds. (Use `bash -lc` in interactive ssh.)
- [ ] If GPU: ollama module loaded (transitively brings CUDA 12.8) — `ollama --version` works after PATH export. The driver version is auto-matched.
- [ ] `.venv` exists and has the project's deps
      (`source .venv/bin/activate && pip list | grep -i langchain`).
- [ ] `~/.aegis_env` exists (mode 600) and has `NEO4J_PASSWORD` set.
- [ ] `PYTHONPATH` is set in the job script (`$PWD:$PYTHONPATH`).
- [ ] `LANGFUSE_ENABLED` matches what you want (default: `false`).

## Resources

- [ ] `--account` matches your project's account.
- [ ] `--partition` matches the node type you need (CPU vs GPU).
- [ ] `--qos` is appropriate (long vs short).
- [ ] `--time` is generous enough (2× estimated runtime is a safe
      buffer; too long lowers priority).
- [ ] `--mem` is enough (use `~16G` for a typical eval; `~32G` for ETL
      phase 3; `~64G+` for full project).
- [ ] If GPU: `--gres=gpu:1` (or whatever the model needs).
- [ ] `--output` and `--error` are explicit (default name is fine,
      `slurm-%j.out`).

## Storage

- [ ] `df -h /home /projects/F202512235CPCAA1 /tmp` shows free space (>20% is a safe margin). Note: Deucalion does NOT export `$WORK` or `$SCRATCH`.
- [ ] Your data tier is right: code in `~/aegis-kg` (NFS), per-job scratch in `/tmp/aegis-job-${SLURM_JOB_ID}`, shared model cache in `/projects/F202512235CPCAA1/CyberMetric_Deucalion/ollama_data/models`.
- [ ] If you need persistence beyond the job: results are written to
      `~/aegis-kg/...` (not in `/tmp`).

## Port and service coordination

- [ ] Neo4j (7475/7688) and Ollama (11434) ports are free on the target
      node, or you are using pattern B (shared service job).
- [ ] No other jobs of yours are on the same node
      (`squeue -u $USER -t RUNNING`).

## Smoke test (recommended, especially for first run)

- [ ] `python -c "from core.env import load_env; load_env()"` succeeds.
- [ ] `python -m py_compile core/agent/graph/nodes.py` succeeds.
- [ ] If starting Neo4j inside the job: the startup script starts and
      `curl http://localhost:7475` returns 200 within 60 s in a
      test allocation.

## Final check

- [ ] You have a copy of the job command in your shell history
      (`history | tail -10`).
- [ ] You have a way to cancel the job (`JOBID=$(sbatch --parsable ...)`).
- [ ] You have read `references/09-troubleshooting.md` for the most
      likely failure modes.

If any item is unanswered, **stop and ask the user** before submitting.

## Script Design Pre-Flight (for `sbatch/*.sh` authors)

These checks run *before* you submit, not after the job fails. Each
maps to a real failure documented in `docs/lessons-learned.md` (in
the consuming project).

### The script itself

- [ ] `set -euo pipefail` is on the first non-comment line.
- [ ] A timestamped `.bak` of the script exists in `sbatch/.bak/`
      (`cp … .bak.$(date +%Y%m%d_%H%M)`).
- [ ] The script `source`s a shared preamble (e.g. `examples/aegis-common.sh`)
      for `CUDA_HOME`, `DS_BUILD_OPS`, cache dirs, `HF_HUB_OFFLINE`.
- [ ] No `python -c "..."` contains unquoted literals.
      `grep -nE 'python -c\s+"[^"]*\b[A-Za-z_]+ [A-Za-z]' sbatch/*.sh`
      returns empty.
- [ ] `--output` and `--error` use absolute paths, or `--chdir` is set
      to the project root.
- [ ] `gpus`/`nproc_per_node` derivation has a hard-coded fallback
      (`gpus=${SLURM_GPUS_ON_NODE:-2}; gpus=${gpus:-2}`).
- [ ] `AEGIS_MAX_NEW_TOKENS` (or equivalent) is ≤ 16384 unless justified
      and tested for the target model + GPU topology.
- [ ] After any `sed`/`replace`, `grep -n "<old pattern>"` returns 0 hits.

### Before submission

- [ ] `sinfo -t idle -p <partition>` shows enough GPUs for the topology
      you're requesting. If a bigger-GPU partition is also idle, prefer
      it (2×80GB over 4×40GB).
- [ ] `python -c "import deepspeed; print(deepspeed.__version__)"` works
      on the target node (after `CUDA_HOME` / `DS_BUILD_OPS=0` /
      `DS_BUILD_AIO=0`).
- [ ] `python -c "import aegis_phase1.v2.output.<doc_xx>"` (and
      sibling modules) returns silently. If not, the shim is missing.
- [ ] `python -c "import torch; print(torch.cuda.mem_get_info())"` shows
      the budget matches the model's KV cache at
      `AEGIS_MAX_NEW_TOKENS × seq_len`.
- [ ] A reproduce-able way to set `CUDA_LAUNCH_BLOCKING=1` is documented
      in the script (commented or behind a flag), so the next
      `cudaErrorLaunchFailure` gives the real kernel.

### After submission

- [ ] Tail the log immediately (`tail -f slurm-<JOBID>.out`).
- [ ] After ~5 min, `grep -nE "ERROR" slurm-<JOBID>.out` returns empty
      (or only the benign `Ollama not reachable` fallback warning).
- [ ] `scontrol show job <JOBID> | grep JobState` confirms the
      authoritative state (don't trust `squeue` alone).

If any item is unanswered, **stop and resolve it** before submitting.
