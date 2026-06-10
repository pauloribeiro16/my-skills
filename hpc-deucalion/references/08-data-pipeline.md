# 08 — Data Pipeline: ETL, Eval, Batch Orchestration

This document shows how to translate AEGIS-KG's local pipelines into
batch jobs on Deucalion.

## ETL phases (project overview)

See `core/AGENTS.md` §2 for the three-phase architecture:

| Phase | What | Cost profile |
|-------|------|--------------|
| Phase 1 | Regulations, domains, subdomains, articles, clauses | LLM calls × clauses; I/O medium |
| Phase 2 | Obligations, goals, clause-subdomain mappings | LLM calls; I/O medium |
| Phase 3 | Tensions, complementarity, timelines, output docs | LLM calls + doc generation; I/O high |

ETL writes to **Neo4j** and generates CSVs/documents under `reports/`.

## ETL on HPC — pattern A (one job, everything inside)

`examples/run-etl.sbatch` is the template. It:

1. Allocates a compute node.
2. Starts Neo4j on that node.
3. Waits for HTTP to respond.
4. Runs `python -m cases.<case>.etl.phase<N>.01_load_*`.
5. Runs all subsequent phase scripts in order.
6. Stops Neo4j.

For Phase 3 (the heaviest), consider requesting a larger node
(`--mem=64G`, `--time=12:00:00`).

## Eval on HPC — pattern A (one job, small eval)

`examples/eval-batch.sbatch` is the template. It:

1. Allocates a node (CPU or GPU depending on the model).
2. Starts Neo4j + Ollama inside the same job.
3. Runs `python core/eval/run_eval.py --case cases/case1 --task T001 --trials 3`.
4. Stops services.

**Use the eval-runner skill for the actual command sequence** — it
defines the progressive batching rules (1 task → 2-3 → 5). On HPC, the
1-task smoke test is even more important because failed runs waste GPU
hours.

## Eval on HPC — pattern B (job array, many tasks)

For the full eval (78+ tasks), submit a **job array** that runs one
task per array slot. Each slot needs its own Neo4j + Ollama. To avoid
the cost of starting them 78 times, do one of:

- Submit a **service job** for Neo4j + Ollama (long-lived) and have
  each array task connect to it (pattern B in `05-running-neo4j.md`).
- Coalesce array tasks: `#SBATCH --array=0-9` with each task running
  8 eval tasks in series. 10 array jobs × 8 tasks = 80 tasks, only
  10 service starts.

**Always start with 1 task (pattern A) to confirm the pipeline works,
then move to pattern B for scale.**

## Data transfer into the cluster

For committing a small repo, plain `git clone` is enough. For large
external datasets (e.g., regulation PDFs):

```bash
# On your laptop, prepare a tarball
tar czf regs.tgz regs/ --exclude='*.pdf.bak'
scp regs.tgz paulinho@login.deucalion.macc.fccn.pt:
# On the cluster
ssh paulinho@login.deucalion.macc.fccn.pt
tar xzf regs.tgz -C ~/aegis-kg/data/
```

For very large data, use `rsync` over SSH (faster on re-runs because of
delta transfer):

```bash
rsync -avz --progress regs/ paulinho@login.deucalion.macc.fccn.pt:~/aegis-kg/data/regs/
```

## Output collection

Collect `reports/`, `traceability_*.csv`, `traceability_*.xlsx` after
the job:

```bash
# On your laptop
rsync -avz paulinho@login.deucalion.macc.fccn.pt:~/aegis-kg/reports/ ./reports-deucalion/
```

The job script should also copy results to `~/aegis-kg/results/$JOBID/`
inside a `trap EXIT` so they survive scratch purges.

## Langfuse on HPC — Cloud, not self-host

The project uses **Langfuse Cloud** (`https://cloud.langfuse.com`) on
HPC, not a self-hosted instance. This is the recommended path because:

- No Docker / Apptainer / Postgres / Clickhouse / Redis / MinIO on the
  cluster.
- No SSH tunnels, no VPN, no reverse port forwarding.
- Traces go from the compute node directly to `cloud.langfuse.com` via
  HTTPS.

### Required env vars

In `~/.aegis_env` on the cluster (mode 600, never committed):

```bash
export LANGFUSE_ENABLED="true"
export LANGFUSE_BASE_URL="https://cloud.langfuse.com"
export LANGFUSE_PUBLIC_KEY="pk-lf-..."
export LANGFUSE_SECRET_KEY="sk-lf-..."
```

You can find / rotate these at
`https://cloud.langfuse.com` → Settings → API Keys.

### Behaviour without internet on the compute node

**Confirmed:** login node has full internet. Compute nodes have SPOTTY
egress. If the node cannot reach `cloud.langfuse.com`:

- The Langfuse SDK **fails silently** — the job does NOT crash.
- Traces are lost for that run.
- The rest of the pipeline (agent, LLM calls, results) is unaffected.
- This is **acceptable**: the agent's output is still printed to
  `slurm-*.out` and saved to `~/aegis-kg/results/`.

To check egress inside a job:

```bash
curl -sf --max-time 8 https://cloud.langfuse.com && echo OK || echo FAIL
```

The Langfuse SDK DOES retry, but if the node has no route, traces are
lost. Do not depend on traces for correctness — use them for debugging
and cost tracking only.

### Cost / budget

Langfuse Cloud's free tier is **50,000 traces/month**.

| Run | Approx traces | % of free tier |
|-----|---------------|----------------|
| 1 task × 1 trial (smoke) | 3-5 | negligible |
| 5 tasks × 3 trials | 50-75 | negligible |
| 78 tasks × 3 trials (full eval) | 700-1000 | ~2% |
| 10 full evals/month | ~10k | ~20% |

**Recommendation:** keep `LANGFUSE_ENABLED=true` for HPC runs that you
actively debug, set it to `false` for routine reruns and local
iteration. The sbatch templates respect `~/.aegis_env`.

### Self-hosting on HPC (only if the user explicitly asks)

If Langfuse Cloud is not an option (e.g., data residency, air-gapped
cluster), self-hosting requires:

- Apptainer (or Docker, if the site permits) for the langfuse container.
- A dedicated `sbatch` service job holding the container.
- A shared storage path for Postgres/Clickhouse/Redis/MinIO data.
- Coordination across worker jobs (Pattern B from
  `05-running-neo4j.md`).

This adds substantial complexity — **confirm with the user** before
going this route. Default to Cloud.

## Caching repeated work

The project's eval pipeline can be slow. To avoid repeating the same
LLM call:

- The eval runner should already cache via Ollama. Verify by
  re-running and checking latency.
- ETL scripts: results are written to Neo4j. Re-running is idempotent
  if the scripts use `MERGE` (check before re-running on a populated
  DB).

## Stop conditions

- The job needs more than 24 h of walltime → break into smaller
  sub-jobs with checkpointing.
- The job needs to coordinate across nodes (e.g., parallel ETL) →
  ask the user; pattern needs review.
- The output dir fills up → check `df -h ~/aegis-kg` before submission.
