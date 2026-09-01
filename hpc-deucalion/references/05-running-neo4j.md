# 05 — Running Neo4j on Deucalion

## Why this is different from local

- On a workstation, Neo4j runs as a daemon in the background indefinitely.
- On HPC, **long-running services are forbidden on login nodes** and are
  tied to the lifetime of a `sbatch` job. The job ends → Neo4j dies.
- The project's port rule still applies: **7688 (Bolt) and 7475 (HTTP)**
  on whatever node Neo4j runs on.

## Three deployment patterns

### Pattern A: Neo4j inside the same job as the workload (simplest)

Submit one `sbatch` job that:
1. Starts Neo4j in the background.
2. Waits for Neo4j to be ready.
3. Runs the ETL or eval.
4. Stops Neo4j.

This is the **default for ETL and small eval runs**. See
`examples/neo4j-server.sbatch` for a self-contained script and
`examples/run-etl.sbatch` for the ETL workflow.

Pros: trivial, no coordination across jobs.
Cons: each job pays the Neo4j startup cost (30–60 s).

### Pattern B: Dedicated Neo4j service job, separate from workload

Submit two `sbatch` jobs:
- Job 1: `srun neo4j console` (or `neo4j start` then polling). Lives
  hours/days. Holds the DB.
- Job 2: workload (ETL/eval/agent) connects to job 1's hostname.

Use `squeue -j <JOBID> -o "%N"` to discover the compute node of job 1.
Then `sbatch --dependency=after:<JOBID>` or `--nodelist=cn01` to pin
job 2 to the same node.

Pros: Neo4j starts once, reused across many jobs.
Cons: requires `--dependency` coordination; if job 1 dies, all jobs 2 die.

### Pattern C: External / shared Neo4j service (if the site offers one)

Some sites run a cluster-wide Neo4j. Ask the user. If it exists, the
project just connects to it via env vars (`NEO4J_HTTP_URL`,
`NEO4J_BOLT_URL`).

**Use pattern A by default. Use B only if the user requests it. Use C if
the site provides it.**

## Data dir location

Put Neo4j's data dir on `/tmp/aegis-job-${SLURM_JOB_ID}` (per-job, ephemeral), not `~/aegis-kg` (NFS, slow). Note: Deucalion does NOT export `$SCRATCH` or `$WORK`.

```bash
export NEO4J_DATA_DIR="/tmp/aegis-job-${SLURM_JOB_ID}/neo4j-data"
# Then point neo4j.conf at it (or symlink ~/.neo4j to it).
```

## Startup checklist inside the job

```bash
# 1. Activate venv
source ~/aegis-kg/.venv/bin/activate
export PYTHONPATH="$HOME/aegis-kg:${PYTHONPATH:-}"

# 2. Start Neo4j
neo4j start
# (or `neo4j console` if running under srun; or `bin/neo4j` directly)

# 3. Wait for HTTP to respond
for i in {1..30}; do
  curl -sf http://localhost:7475 >/dev/null && break
  sleep 2
done
curl -sf http://localhost:7475 || { echo "Neo4j not ready"; exit 1; }

# 4. Run the workload
python ...
```

## Teardown

```bash
neo4j stop
# or kill the process group
pkill -f neo4j
```

Always include teardown in a `trap EXIT` so a failed ETL does not leak a
Neo4j process.

## Port collisions on a shared node

Two jobs landing on the same compute node will collide on 7475/7688. To
avoid:

- Request exclusive node access: `#SBATCH --exclusive`.
- Or use different ports per job and override via `neo4j.conf`:
  `server.bolt.listen_address=:17688` etc. **This breaks the project
  port rule — only do it if you must, and never in committed code.**

## Security note

Inside the cluster, the firewall typically restricts ports to cluster
nodes only. So 7475 being open is acceptable. From your laptop, you
**must** SSH-tunnel to reach Neo4j (see `01-access.md`).
