# 07 — SLURM Jobs: sbatch, srun, squeue, partitions, QoS

## Job anatomy

A `sbatch` script is a regular bash script with `#SBATCH` directives at
the top. The directives are comments to bash but instructions to SLURM.

```bash
#!/usr/bin/env bash
#SBATCH --job-name=aegis-etl-phase1
#SBATCH --account=f202512235cpcaa1g
#SBATCH --partition=dev-x86
#SBATCH --chdir=/home/paulinho/aegis-kg
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=04:00:00
#SBATCH --output=slurm-%j.out
#SBATCH --error=slurm-%j.err

set -euo pipefail
source .venv/bin/activate
export PYTHONPATH="$PWD:$PYTHONPATH"

# ... actual work ...
```

## Common directives

| Directive | Meaning | Default |
|-----------|---------|---------|
| `--job-name` | Human-readable name in `squeue` | `sbatch` script basename |
| `--account` / `-A` | SLURM account (project/group) | your default |
| `--partition` / `-p` | Logical pool of nodes | site default |
| `--qos` / `-q` | Quality of Service (priority, walltime cap) | site default |
| `--nodes` / `-N` | Number of nodes | 1 |
| `--ntasks-per-node` | MPI ranks per node | 1 |
| `--cpus-per-task` / `-c` | CPU cores per task | 1 |
| `--mem` | RAM per node | varies |
| `--gres` | Generic resources (e.g. `gpu:1`) | none |
| `--time` / `-t` | Walltime `HH:MM:SS` | site default (often 1h) |
| `--output` / `-o` | Stdout file (`%j` = jobid) | `slurm-%j.out` |
| `--error` / `-e` | Stderr file | combined with `-o` |
| `--chdir` | Working directory inside the job | submit dir |
| `--exclusive` | Reserve the whole node | off |
| `--dependency` | Wait for another job | none |

## `srun` vs `sbatch`

- `sbatch script.sh` → submit a script, return immediately.
- `srun command` → run a command inside an existing allocation
  (created by `sbatch` or `salloc`). Useful for parallel steps inside a
  job.
- `salloc` → start an interactive allocation (then `srun` inside it).

For AEGIS-KG, **use `sbatch`**. `salloc` is for interactive debugging
only.

## Checking job state

```bash
squeue -u $USER                          # your jobs
squeue -j <JOBID> -o "%N"                # hostname of the running job
scontrol show job <JOBID>                # everything about one job
sacct -j <JOBID> --format=JobID,State,Reason,Elapsed,MaxRSS
sinfo -p dev-x86             # partition state
```

State codes you will see:
- `PENDING` (PD) — waiting for resources.
- `RUNNING` (R) — executing.
- `COMPLETING` (CG) — finishing (writing output).
- `COMPLETED` (CD) — done.
- `FAILED` (F) — non-zero exit, timeout, or node failure.
- `CANCELLED` (CA) — you `scancel`-ed it.
- `TIMEOUT` — walltime hit.

Common pending reasons:
- `Resources` — waiting for CPU/RAM/GPUs.
- `Priority` — other jobs in the queue have priority.
- `QOSMaxJobsPerUserLimit` — you have too many running jobs in this QoS.
- `AssocGrp*` — account-level limit hit.

## Partitions (typical)

| Partition | Use |
|-----------|-----|
| `dev` | Short, interactive debug jobs (often ≤30 min) |
| `normal` | Standard batch jobs |
| `gpu` | GPU-enabled nodes |
| `highmem` | Large-memory nodes |
| `long` | Walltime > 24h (may have lower priority) |

The exact names and limits are site-specific. Always run `sinfo` to
discover them.

## QoS

QoS controls **priority**, **preemption**, and **per-user limits**.
Common ones:

| QoS | Behavior |
|-----|----------|
| `normal` | Default |
| `priority` | Higher priority, may consume more allocation |
| `long` | Longer walltime, lower priority |
| `preempt` | Can be preempted by higher-priority jobs |

## Job arrays

For "run the same job over many inputs" (e.g., 78 eval tasks):

```bash
#SBATCH --array=0-77
# Inside the script:
TASK_ID=$((SLURM_ARRAY_TASK_ID + 1))
echo "Running task T$(printf '%03d' $TASK_ID)"
python -m core.eval.run_eval --task "T$(printf '%03d' $TASK_ID)" ...
```

Each array task is an independent job that can land on a different
node. Logs go to `slurm-%A_%a.out` (use `%A` for array id, `%a` for
task id).

**Caveat:** each array task may start its own Neo4j/Ollama. Use pattern
A (`05-running-neo4j.md`) for the first MVP, then move to a shared
service job.

## Dependencies

```bash
# Submit job 2 only after job 1 succeeds
JID1=$(sbatch --parsable job1.sbatch)
sbatch --dependency=afterok:$JID1 job2.sbatch
```

Dependency kinds: `after`, `afterok`, `afternotok`, `afterany`,
`aftercorr` (run after corresponding task in an array). Use `afterok`
when the second job depends on the first succeeding.

## Cancellations and cleanups

```bash
scancel <JOBID>                  # cancel one job
scancel -u $USER                 # cancel all your jobs
scancel --state=PENDING -u $USER # only the queued ones
```

## `--exclusive` vs sharing

For AEGIS-KG, recommend `--exclusive` on Neo4j/Ollama service jobs to
avoid port collisions. For lightweight eval jobs, sharing is fine.

## When to ask the user

Stop and ask the user before you guess:

- `--account` (you might have multiple).
- `--partition` (you might not have GPU access).
- `--qos` (mistakes can waste allocation or trigger preemption).
- `--time` (too short = job killed, too long = low priority).
- Anything that touches `$HOME` cleanup.
