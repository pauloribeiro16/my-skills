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
