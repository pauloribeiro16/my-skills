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

## Standard facts — learned the hard way, do not relitigate

These are facts that have bitten us in real sessions. Treat them as
known facts from now on; if a new situation contradicts them, gather
evidence and surface it rather than re-deriving.

### Ollama model tags (must match the exact library name)

| Tag | Library dir on cluster |
|-----|------------------------|
| `granite4.2:30b` | `.../ollama_data/models/manifests/registry.ollama.ai/library/granite4.2/` |
| `muse-glimmer:30b` | `.../library/muse-glimmer/` |
| `qwen3.8:27b` | `.../library/qwen3.8/` |
| `qwen3.5:27b` | `.../library/qwen3.5/` |
| `qwen3.5:9b` | `.../library/qwen3.5/` |
| `gemma4:26b` | `.../library/gemma4/` |
| `gemma4:e2b` / `gemma4:e4b` | `.../library/gemma4/` |
| `nemotron-3.5-lightning:30b` | `.../library/nemotron-3.5-lightning/` |
| `ornith:9b` | `.../library/ornith/` |
| `glm-4.7-flash:latest` | `.../library/glm-4.7-flash/` |
| `gpt-oss:20b` | `.../library/gpt-oss/` |
| `phi4:14b` | `.../library/phi4/` |
| `mistral:7b`, `ministral-3:8b`, `llama3.2:1b` | `.../library/{mistral,ministral-3,llama3.2}/` |

**Trap to avoid:** short-form tags (`nemotron3.5:30b`, `granite:30b`,
`ornith-1.5:9b`) silently trigger `ollama pull` — which fails because
the cluster has **no egress** to `https://registry.ollama.ai` from
compute nodes. Result: minutes wasted, job aborts. Verify the cache
directory before `sbatch`, not the tag string alone. Use
`examples/gpu-pick.sh <tag>` to also pick the right partition.

### Two Ollama binaries — pick the right one for the model

| Binary | Version | Used for |
|--------|---------|----------|
| `$BD/bin/ollama` (`$BD=/projects/F202512235CPCAA1/CyberMetric_Deucalion`) | **0.31.1** | `serve` for known architectures (gemma3/4, qwen3.x, llama, mistral, phi, granite4.2, muse-glimmer) |
| `$BD=/projects/F202512235CPCAA1/graphify-methodology/bin/ollama` (`+ lib/ollama` in LD_LIBRARY_PATH) | **0.32.13** | `serve` for unknown/edge architectures AND **the only one that can `ollama pull` modern manifests** |

0.31.1 cannot resolve modern manifests (`granite4.2:30b` fails with
`unknown model architecture`). When in doubt, use 0.32.13 from
`graphify-methodology/`.

### Parallel jobs (proven pattern, 2026-09-02)

- **Across nodes: safe.** Multiple scouts on different nodes each get
  their own GPU and port 11434 — confirmed with JOBs 1869099/100/101.
  Each lives on its own `--gres=gpu:1`.
- **Same node: 2 jobs collide** on `11434` (Ollama server). Resource
  contention shows up as `Connection refused` in the 2nd job and the
  warm-up fails. Mitigation: check `squeue -o "%.6R"` (Reason
  column); if both jobs say the same node and it isn't yet fully
  routed, cancel and submit again.
- **Walltime budgets (as of 2026-09-02, battle-tested):**
  - Phase 1B scout (4 LLM calls + Doc 05 only): **30 min**.
  - Phase 1+2+3 scout-full (full pipeline, 9 docs + xlsx): **1 h 30**.
  - Full run-all (warm-up + pipeline + bulk output): **8 h**.

### Stale `.pyc` cache after a code sync (proven 2026-09-02)

When you sync updated Python files to Deucalion (via `scp`, `rsync`, or
`tar extract`) the cluster's `_archive/.../markdown_parser.py` is
fresh but the corresponding `__pycache__/*.pyc` is **stale**. Python
happily loads the old bytecode, finds `ImportError: cannot import name
'X'`, and the job aborts ~1 minute after warm-up with a confusing trace.

**Always include these in sbatch scripts before `python` is invoked:**

```bash
echo "=== wiping stale .pyc + __pycache__ (defense-in-depth) ==="
find "$PROJ/src" -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
find "$PROJ/src" -name "*.pyc" -delete 2>/dev/null || true
PYTHONDONTWRITEBYTECODE=1
export PYTHONDONTWRITEBYTECODE
```

The byte-code-suppression flag is also useful for `--gres` shared GPU
runs where two Python processes might write to the same `__pycache__`
directory simultaneously and corrupt each other.

### `scp` and `$HOME` quota

- The user's `$HOME` on Deucalion has a tight quota (a few GB).
  `scp ... ~/` often fails with `Disk quota exceeded`. **Stage through
  `/tmp` (per-job, auto-cleared)**: `scp foo.py user@login:/tmp/`,
  then `ssh user@login 'cp /tmp/foo.py <dest>'`.
- Two `scp` calls with the same basename to the same `/tmp/`
  overwrite each other (no subdir mapping). Use unique basenames, or
  combine into a single `tar -cz` first.
- Always `chmod +x` after the copy if the destination is a script.

### Job-name uniqueness — `squeue` is unreadable if everything is `aegis_scout`

The `--job-name` directive is pre-evaluated; you cannot use `$1` in it.
For multiple parallel scouts, pass the sanitised model tag via the
`sbatch` CLI:

```bash
sbatch -J "aegis_<sanitised-tag>_full" <script> <model:tag>
```

where `<sanitised-tag>` is the model tag with `:` and `.` replaced by
`_`. Use the wrapper `scripts/scouts/scout-full-submit.sh` to print the
exact line — otherwise each scout ends up with the same
`aegis_scout_full` job-name and `squeue` becomes a wall of duplicates.

### Egress

Compute nodes cannot reach `registry.ollama.ai` (HTTPS timeout). New
models must be pulled on the **login node** with the **graphify
0.32.13** binary in `/projects/F202512235CPCAA1/graphify-methodology`,
then the manifests land in the shared
`/projects/F202512235CPCAA1/CyberMetric_Deucalion/ollama_data/models/`
cache and are visible to compute nodes.

### Monitoring jobs

- `squeue -u $USER` — quick status (only running/pending; finished jobs
  drop off after a few minutes).
- `sacct -j <JOBID> --format=JobID,State,ExitCode,Elapsed,MaxRSS` —
  post-mortem state and resource use.
- `scontrol show job <JOBID>` — full live state (good for
  diagnostics like Reason, StdOut path, NodeList).
- `cat /projects/<...>/<project>/logs/scout_runs/scout_<tag>_<JOB>.log`
  for the per-run structured log (preferred over `slurm-*.out`).
- `cat /projects/<...>/<project>/slurm-<script>-<JOB>.out` for
  stdout/stderr (slurm-managed, slow to appear).

### Path conventions for AEGIS-Phase-1

- **Active project dir:** `/projects/F202512235CPCAA1/CyberMetric_Deucalion/aegis-phase1`.
  (The old `~/aegis-kg` path is the CORR-057 eval layout; superseded.)
- **Output dirs** (created by `--output`):
  - `output/run_<model>_<JOB>` for full run-alls.
  - `output/scout_<model>_<JOB>` for Phase 1B-only scouts.
  - `output/scout_full_<JOB>` for pipeline-complete scouts.
- **Run logs:** `logs/scout_runs/scout_<tag>_<JOB>.log`.
- **Per-model JSONL traces:** `logs/phase1/<model>/v2/pipeline_<model>.log`.

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

### Ollama version split (2026-09-01, battle-tested)

There are **two Ollama binaries** on the cluster and they are NOT
interchangeable:

| Binary | Version | Use for |
|--------|---------|---------|
| `$BD/bin/ollama` (`$BD` = `/projects/F202512235CPCAA1/CyberMetric_Deucalion`) | **0.31.1** | `ollama serve` for models whose architecture it knows (gemma3/gemma4, qwen3.x, llama, mistral, phi, granite4.2) |
| `/projects/F202512235CPCAA1/graphify-methodology/bin/ollama` (+ `lib/ollama` in `LD_LIBRARY_PATH`) | **0.32.13** | `ollama pull` of NEW model tags (0.31.1 cannot resolve modern manifests — `granite4.2:30b` fails, `granite4.2:30b` vs `granite4:30b` matters) AND `serve` for models whose renderer/arch it doesn't know (muse-glimmer → `unknown model architecture` under 0.31.1) |

**Pull recipe (login node, spotty egress):** serve 0.32.13 locally, pull
one model at a time with `timeout 600`, verify the manifest appeared
under `ollama_data/models/manifests/registry.ollama.ai/library/<model>/`.
Exact tag names matter — check the Ollama library page first
(`granite4.2:30b` exists; `granite4:30b` does not; `nemotron-3.5-lightning:30b`,
`muse-glimmer:30b|latest`, `ornith:9b` all pulled successfully 2026-09-01).

## AEGIS Phase 1 scout recipe (2026-09-01, battle-tested)

The aegis-phase1 project runs model scouts (Phase 1B only: 4 LLM calls)
on `dev-a100-80`. Use the generic sbatch
`aegis-phase1/examples/deucalion/scout-bench-m-aegis.sbatch` — pass the
model as a **positional argument**, never via `--export` (flaky):

```bash
# from the aegis-phase1 dir on the login node:
sbatch examples/deucalion/scout-bench-m-aegis.sbatch granite4.2:30b
```

Rules encoded in that sbatch (do not relearn the hard way):

1. **Sequential, never parallel.** One Ollama per node. Three 30B scouts
   in parallel → `Connection refused` / `Server disconnected` on all of
   them. Submit, wait for SUCCESS, then submit the next.
2. **Logs to NFS**, not compute-node scratch: `--out/--err` point to
   `$PROJ/slurm-scout-bench-m-<JOBID>.{out,err}` and a run log to
   `$PROJ/logs/scout_runs/scout_<model>_<JOBID>.log`. Scratch logs are
   unrecoverable after the job ends.
3. **Warm-up with retries before python.** 5 attempts, 180s timeout each;
   abort before wasting the pipeline run if the model won't load.
4. **Walltime:** budget ≥2× the slowest previous scout (qwen3.8 = 18 min,
   ornith:9b = 5:36, 30B models ≈ 15-25 min). 30 min is the working
   default for Phase 1B scouts on 1× A100-80.
5. **Active project dir:**
   `/projects/F202512235CPCAA1/CyberMetric_Deucalion/aegis-phase1`
   (NOT `~/aegis-kg` — that is the old CORR-057 eval layout).
6. **Monitor:** `squeue -u $USER` + `sacct -X -j <JOBID> -n -P -o
   "JobID,State,ExitCode,Elapsed"`. Success = `STATUS: SUCCESS` in the
   run log AND `rationale_by_reg has 2 entries` in stderr.
7. **Post-run:** scp Doc 05 to the local mirror
   `<workspace>/Deucalion/results/<model>_<jobid>/`, then evaluate:
   `PYTHONPATH=src python3 scripts/eval/generate_report.py --run-dir
   <mirror_dir> --preproc preproc_out --output-{dir,md,json} ... --use-parser-gate`
   (see `execution/reports/EVAL_PROTOCOL.md` for the judge pass).

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
| `examples/gpu-pick.sh` | VRAM estimate + smallest-fit partition for a model tag | **Before any sbatch** that picks a partition based on the model |

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

**Last Updated:** 2026-09-01

## Companion: Human-Oriented Workflow Doc

The consuming project ships `docs/deucalion/08-hpc-workflow.md` which is
the step-by-step async cycle (workstation → login → sbatch → wait →
collect → iterate) and the queue-handling strategies. Point users there
for the narrative view; this `SKILL.md` is the operational reference.
