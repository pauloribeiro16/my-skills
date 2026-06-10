# 00 — Deucalion Overview

> Read this first if you are new to the cluster.

## What is Deucalion?

Deucalion is a Portuguese HPC cluster operated by INESC-TEC / MACC. It is a
shared resource: many users share login nodes, compute nodes, and storage.
Every action must respect fair-use policies.

## Two classes of nodes

| Class | Role | Use it for | Don't use it for |
|-------|------|------------|------------------|
| **Login node** | Interactive shell, job submission, editing | `git`, `vim`, `sbatch`, `squeue`, `module`, `pip install` of pre-built wheels | Long-running services, heavy CPU, large compilations, Neo4j/Ollama |
| **Compute node** | Batch work, dedicated to a job | Anything `srun`/`sbatch` launches, including services | Interactive editing (no shell) |

The login node kills processes that exceed soft CPU/memory limits.

## Account model

- You authenticate with your **institutional account** (LDAP/SSO + password
  or SSH key, possibly + 2FA).
- You are a member of one or more **SLURM accounts** (groups/projects).
  Each account has its own allocation, partition access, and walltime cap.
- Use `sacctmgr show assoc user=$USER` to see your accounts.

## Scheduling at a glance

```
            sbatch script.sbatch
                       │
                       ▼
   ┌─────────────  SLURM controller  ──────────────┐
   │ priority, fair-share, backfill, preemption    │
   └─────────────┬───────────────────┬─────────────┘
                 │                   │
                 ▼                   ▼
         ┌──────────────┐    ┌──────────────┐
         │ compute node │    │ compute node │
         │   job A      │    │   job B      │
         └──────────────┘    └──────────────┘
```

- Jobs are queued (`PENDING`) until resources are available.
- `squeue -u $USER` shows the queue. `scontrol show job <JOBID>` shows why a
  job is pending (`Priority`, `AssocGrp*`, `Resources`).
- `sacct` is the historical view (post-mortem).

## What changes vs. local workstation

| Local workstation | Deucalion |
|-------------------|-----------|
| Docker works without sudo | Docker may be unavailable to users; check first |
| Neo4j runs in background forever | Neo4j must be inside a `sbatch` job; ends with it |
| Free port 7475 / 7688 | The same ports work (and we enforce them), but only one process can hold them on a given node |
| Internet unrestricted | Some compute nodes have no internet egress — pip install may fail inside the job |
| Storage = one disk | Two persistent: `/home/$USER` (NFS, 22TB) + `/projects/F202512235CPCAA1` (Lustre, 8.2PB); per-job: `/tmp` |
| Background services easy | Use `screen`/`tmux` is forbidden on login nodes; use `sbatch` with checkpointing |
| `git push` works | Some sites require SSH key registered with the portal first |

## First-time checklist

1. Confirm account is active: `id $USER`, `sacctmgr show assoc user=$USER`.
2. Confirm SSH works to `login.deucalion.macc.fccn.pt`.
3. Confirm 2FA flow (if any).
4. Confirm storage tiers are mounted: `df -h /home /projects/F202512235CPCAA1 /tmp`. Note: Deucalion does NOT export `$WORK` or `$SCRATCH`.
5. Confirm at least one Python module is available: `module avail python`.
6. Confirm GPU is available (if needed): `sinfo -p gpu`.

## Where to look for site-specific info

- **User guide / docs** (URL, PDF) — site-specific; ask PI or check the
  institutional portal.
- **Status page** — for outages / maintenance windows.
- **Helpdesk / ticketing** — for access issues.
- **`module avail`** on the cluster itself — for the canonical software list.
- **`sinfo`** — for the canonical partition/QoS list.

**Do not** hardcode any of these in scripts. Read them at submit time or
let the user provide them as parameters.
