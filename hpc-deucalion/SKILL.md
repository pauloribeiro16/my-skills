---
name: hpc-deucalion
description: "Operate AEGIS-KG on Deucalion HPC: SLURM, sbatch, srun, compute nodes, Lmod modules, $SCRATCH/$WORK, GPU partitions. Use when running on deucalion, hpc, slurm, or cluster."
---

# HPC Deucalion

Operational knowledge for running **AEGIS-KG** on the **Deucalion** supercomputer.
Deucalion is a shared HPC cluster: it uses **SLURM** for scheduling, **Lmod** for
software modules, has **login nodes** (interactive, lightweight) and **compute
nodes** (batch, dedicated), and exposes tiered storage. Most local-workstation
assumptions (free Docker, persistent background services, free port use) **do
not apply**.

> **Progressive disclosure:** SKILL.md (this file) gives the operational rules
> and quick-start. Detailed topics live in `references/`. Copy-pasteable job
> scripts live in `examples/`. The companion tutorial for humans lives in
> `docs/deucalion/README.md`.

## When to Activate

Activate this skill when **any** of the following is true:

- The user mentions "deucalion", "hpc", "supercomputer", "cluster", "slurm",
  "sbatch", "srun", "squeue", "login node", "compute node", "gpu partition",
  "module load", "$SCRATCH", "$WORK", or "walltime".
- The user asks to run eval/ETL/agent workloads at scale on a shared cluster.
- A workflow needs Neo4j or Ollama as long-running services (these **must** go
  on compute nodes, not login nodes).
- A planned change involves pip-installing heavy packages, moving large CSVs,
  or running a job longer than a few minutes.

## Hard Rules (Non-Negotiable)

These apply to **any** Deucalion work, regardless of task. Violating any of
them is a STOP and report to user.

| # | Rule | Why |
|---|------|-----|
| 1 | **Never run heavy work on a login node.** Login nodes are shared; CPU/disk-heavy work (pip install with compilation, ETL, eval) is forbidden and will be killed. | Multi-user fairness. |
| 2 | **All long-running services (Neo4j, Ollama, Langfuse) run inside `sbatch`/`srun` on a compute node.** They get killed when the job ends — design for that. | Services must not outlive their job. |
| 3 | **Neo4j ports stay 7688 (Bolt) / 7475 (HTTP).** Never hardcode 7687/7474 on Deucalion (those are reserved for the local D3Fend dev container). | Project-wide port invariant. |
| 4 | **Code lives in `~/aegis-kg` (NFS, 22TB).** Lustre is `/projects/F202512235CPCAA1/`. Do NOT assume `$WORK`/`$SCRATCH` env vars exist. | Storage tier policy. |
| 5 | **Use a per-project venv inside the cloned repo, not a shared venv on `$HOME`.** HPC sites wipe `$HOME` shells or move users between login nodes. | Reproducibility. |
| 6 | **Langfuse is opt-in.** Default is `LANGFUSE_ENABLED=false`. Self-hosting on HPC adds Postgres+Clickhouse+Redis+MinIO overhead — only enable if user explicitly asks. | Cost / complexity. |
| 7 | **Never put secrets in `sbatch` scripts or job stdout.** Use `~/.aegis_env` (mode 600) and `source` it from the job script. | Credential safety. |
| 8 | **Always set `--chdir` (or `cd` in the script) to the job submission directory.** HPC file systems behave differently on login vs compute nodes. | Reproducibility. |
| 9 | **Read `references/10-checklist.md` before submitting any job.** It is the single source of truth for pre-flight. | Discipline. |
| 10 | **Stop and ask the user** if you do not know the SLURM account (`-A`), partition (`-p`), QoS (`-q`), or walltime limit. These are site-specific. | Wrong flags = job rejected. |

## Quick-Start (5 Steps)

1. **Access.** SSH to the login node:
   ```bash
   ssh -i /home/epmq-cyber/.ssh/id_ed25519 paulinho@login.deucalion.macc.fccn.pt
   ```
   If 2FA is required, follow the cluster's MFA flow (typically TOTP + SSH key).
2. **Clone the repo (code lives in `~/aegis-kg`).**
   ```bash
   # Deucalion has no $WORK. Code in ~/aegis-kg.
   cd ~
   # HTTPS git clone fails (needs auth). Use tar+scp from workstation:
   #   on workstation: tar --exclude='.venv' --exclude='__pycache__' -czf aegis-kg.tgz aegis-kg/
   #   scp aegis-kg.tgz paulinho@login.deucalion.macc.fccn.pt:~
   #   on cluster: tar xzf aegis-kg.tgz
   ```
3. **Load the modules and create the venv (interactively, on a login node is
   OK for this step — no heavy compute).** Modules need login shell. If
   `module load` fails, use `bash -lc 'python ...'`. venv needs
   `--system-site-packages` (see references/04). See
   `references/04-environment-setup.md`.
4. **Submit a scout first, then the heavy work via `sbatch`.**
   - `examples/scout.sbatch` — 5 min CPU job that prints a full environment report
   - `examples/test-ollama-gpu.sbatch` — real run with Ollama on GPU + Langfuse Cloud
   - `examples/test-ollama-cpu.sbatch` — CPU fallback when no GPU available
   - `examples/neo4j-server.sbatch` — start Neo4j on a compute node
   - `examples/ollama-gpu.sbatch` — start Ollama (with GPU) on a compute node
   - `examples/eval-batch.sbatch` — run the eval harness in batch
   - `examples/run-etl.sbatch` — run the ETL pipeline
5. **Monitor with `squeue -u $USER` and read job logs from
   `slurm-<JOBID>.out`.** See `references/07-slurm-jobs.md` for full
   inspection/debugging.

## Ollama on Deucalion

Ollama is pre-installed at `/projects/F202512235CPCAA1/CyberMetric_Deucalion/bin/ollama`.
Use this path — it's faster and more stable than the module.

```bash
# In your sbatch scripts (or login shell):
export PATH="/projects/F202512235CPCAA1/CyberMetric_Deucalion/bin:$PATH"
export LD_LIBRARY_PATH="/projects/F202512235CPCAA1/CyberMetric_Deucalion/lib/ollama:$LD_LIBRARY_PATH"
export OLLAMA_MODELS="/projects/F202512235CPCAA1/CyberMetric_Deucalion/ollama_data/models"
```

**Models are pre-loaded** in the shared cache above. To add new models,
run `examples/download-models.sbatch` (a separate sbatch job on
`normal-a100-40`). Do NOT `ollama pull` inside AEGIS-KG jobs — compute
nodes have spotty egress to `registry.ollama.ai`.

## Operational Cheat Sheet

| Need | Command |
|------|---------|
| Check queue | `squeue -u $USER` |
| Cancel a job | `scancel <JOBID>` |
| Detailed job info | `scontrol show job <JOBID>` |
| Job efficiency / why pending | `sacct -j <JOBID> --format=JobID,State,Reason,Elapsed,MaxRSS,NTasks` |
| Disk usage | `myquota` (or `lfs quota -u $USER /work`) |
| Available partitions | `sinfo -o "%P %a %D %t" \| sort` |
| Module list | `module avail` |
| Loaded modules | `module list` |
| Show module contents | `module show python/3.11` |
| GPU nodes available | `sinfo -p gpu -o "%P %D %G"` |
| Pre-load model | `sbatch examples/download-models.sbatch` |
| Model cache path | `/projects/F202512235CPCAA1/CyberMetric_Deucalion/ollama_data/models` |
| Ollama binary | `/projects/F202512235CPCAA1/CyberMetric_Deucalion/bin/ollama` |
| Attach to running job (debug) | `srun --jobid=<JOBID> --pty bash` (if granted) |

## Topic Index — Read on Demand

| Topic | File |
|-------|------|
| What Deucalion is, accounts, fair-use | `references/00-overview.md` |
| SSH, login nodes, 2FA, X11 | `references/01-access.md` |
| `$HOME` / `$SCRATCH` / `$WORK`, quotas, performance | `references/02-storage.md` |
| Lmod, Python, CUDA, GCC, MPI | `references/03-software-stack.md` |
| venv, `PYTHONPATH`, `.env`, pip install | `references/04-environment-setup.md` |
| Neo4j on a compute node | `references/05-running-neo4j.md` |
| Ollama + GPU, vLLM alternative | `references/06-running-ollama.md` |
| `sbatch` anatomy, partitions, QoS, accounts | `references/07-slurm-jobs.md` |
| ETL / eval / batch orchestration | `references/08-data-pipeline.md` |
| Quota, GPU, OOM, network, port issues | `references/09-troubleshooting.md` |
| Pre-flight checklist (always read) | `references/10-checklist.md` |

## Templates (Copy-Paste)

| Script | Purpose | When to use |
|--------|---------|-------------|
| `examples/scout.sbatch` | Environment report (account, modules, GPU, internet) | **Always first** — 5 min, no GPU needed |
| `examples/test-ollama-gpu.sbatch` | Real run: Ollama + agent + Langfuse Cloud | GPU available, end-to-end test |
| `examples/test-ollama-cpu.sbatch` | CPU fallback: same pipeline, 10-60x slower | GPU queue >24h or no GPU access |
| `examples/download-models.sbatch` | Pre-pull Ollama models into shared cache | New model needed, before first GPU run |
| `examples/env-setup.sh` | Idempotent env + module loader for login sessions | Source from job scripts |
| `examples/neo4j-server.sbatch` | Start Neo4j on a compute node | When adding Neo4j back to the pipeline |
| `examples/ollama-gpu.sbatch` | Start Ollama on a GPU compute node (as a service job) | Pattern B (shared service for many workers) |
| `examples/eval-batch.sbatch` | Submit eval tasks (1+ tasks, N trials) | Full eval with Neo4j |
| `examples/run-etl.sbatch` | Run an ETL phase end-to-end | ETL with Neo4j |

## How This Skill Coordinates with Others

- **`neo4j-verify`** — invoke before any Neo4j work (HPC or not). Port rules
  still apply (7688/7475).
- **`etl-runner`** — invoke when running ETL. On HPC, the *execution* part of
  ETL must go through `sbatch` (see `examples/run-etl.sbatch`).
- **`eval-runner`** — invoke when running eval. On HPC, prefer batch mode
  with `examples/eval-batch.sbatch` instead of interactive runs.
- **`python-best-practices`** — still required for any Python change. venv
  location differs (per-project inside `~/aegis-kg` instead of `~/shared-venv`).
- **`agents-md-writer`** — invoke when updating `docs/deucalion/` or
  `AGENTS.md` sections related to Deucalion.

## Async Workflow on Deucalion

Running on HPC is **asynchronous**: you submit, the scheduler decides when
your job runs, and you collect results later. The full cycle is:

1. **Workstation:** `git push` your changes
2. **Login node:** `cd ~/aegis-kg && git pull`, edit `.aegis_env` if needed
3. **Login node:** `sbatch scout.sbatch` to verify environment
4. **Login node:** `sbatch test-ollama-gpu.sbatch` (or `-cpu`)
5. **Login node:** `squeue -u $USER` + `tail -f slurm-<JOBID>.out` to monitor
6. **Job ends:** results land in `~/aegis-kg/results/<JOBID>/`
7. **Workstation:** `rsync` results back, inspect, iterate

If the GPU queue is long, see the queue strategy in
`references/07-slurm-jobs.md` and the human-oriented
`docs/deucalion/08-hpc-workflow.md` in the consuming project.

## Stop Conditions

Stop and report to the user if:

- The user gives an ambiguous account/partition/QoS — wrong flags = job rejected.
- A required module is missing on the cluster (`module avail` shows nothing).
- The job hits a quota error — do not retry blindly.
- The user asks to "make Neo4j persistent across jobs" — this requires
  site-specific setup (e.g., a reserved service node). Confirm before
  attempting.
- A `sbatch` script will run >24h without checkpointing — design needs
  review.

## Placeholders

All site-specific values are real. No placeholders to substitute.

| Placeholder | Real value | Source |
|-------------|-----------|--------|
| `<DEUCALION_LOGIN_HOST>` | `login.deucalion.macc.fccn.pt` | Confirmed via SSH |
| `<DEUCALION_ACCOUNT_GPU>` | `f202512235cpcaa1g` | `sacctmgr show assoc user=$USER` |
| `<DEUCALION_ACCOUNT_X86>` | `f202512235cpcaa1x` | Same |
| `<DEUCALION_PARTITION_GPU>` | `dev-a100-40` (short jobs <=4h) / `normal-a100-40` (<=2d) | `sinfo -p gpu` |
| `<DEUCALION_PARTITION_X86>` | `dev-x86` (short) / `normal-x86` (longer) | `sinfo -p x86` |
| `<DEUCALION_QOS>` | `normal` | `sacctmgr show qos` |
| `<DEUCALION_WORK>` | `/projects/F202512235CPCAA1` (Lustre, 8.2PB) | `ls /projects/...` |
| `<DEUCALION_SCRATCH>` | `/tmp` (no persistent scratch; use `/tmp/$JOBID` per job) | `df -h /tmp` |
| `<DEUCALION_PYTHON_MODULE>` | `Python/3.11.3-GCCcore-12.3.0` | `module avail python` |
| `<DEUCALION_CUDA_MODULE>` | (auto via ollama module deps) | -- |
| `<DEUCALION_OLLAMA_BIN>` | `/projects/F202512235CPCAA1/CyberMetric_Deucalion/bin` | Pre-installed |
| `<DEUCALION_OLLAMA_MODELS>` | `/projects/F202512235CPCAA1/CyberMetric_Deucalion/ollama_data/models` | Pre-loaded (102 blobs) |
| `<DEUCALION_OLLAMA_MODULE>` | `ollama/0.20.3-GCCcore-14.2.0-CUDA-12.8.0` (alternative to binary) | `module avail ollama` |
| `<REPO_URL>` | (HTTPS clone fails) — use `tar+scp` | -- |
| `<BRANCH>` | `main` | -- |

**Last Updated:** 2026-06-09

## Companion: Human-Oriented Workflow Doc

The consuming project ships `docs/deucalion/08-hpc-workflow.md` which is
the step-by-step async cycle (workstation → login → sbatch → wait →
collect → iterate) and the queue-handling strategies. Point users there
for the narrative view; this `SKILL.md` is the operational reference.
