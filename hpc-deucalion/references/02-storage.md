# 02 — Storage: Tiers, Quotas, and Layout

Deucalion does NOT set `$WORK` or `$SCRATCH` env vars. There are three
storage tiers with different characteristics.

## Storage tiers

| Tier | Mount | Size | Speed | Lifetime | Backup | Use for |
|------|-------|------|-------|----------|--------|---------|
| `/home/$USER` | `/home/paulinho` | 22TB free | Slow (NFS) | Permanent | Yes | Config, `~/.aegis_env`, SSH keys |
| `/projects/F202512235CPCAA1` | Lustre | 8.2PB | Medium-fast | Permanent | Sometimes | Model cache (pre-loaded), shared data, `bin/` executables |
| `/tmp` | local (per-job) | Node RAM | Fastest | Job only | No | Per-job scratch, Neo4j data dir, model cache overrides |

## Check your quotas

```bash
df -h /home /projects/F202512235CPCAA1 /tmp
```

Output semantics vary; look for two numbers: **used / limit**. If a job
fails with `Disk quota exceeded`, you must clean up before retrying.

## Recommended layout for AEGIS-KG

```
~/aegis-kg/                        # repo (NFS, OK for code)
├── .venv/                         # per-project venv (rebuildable)
├── .pip-cache/                    # pip wheel cache
├── data/phase{1,2,3}/             # committed input CSVs
├── results/<JOBID>/               # committed by jobs on exit
└── .env.deucalion.example

/projects/F202512235CPCAA1/
└── CyberMetric_Deucalion/
    ├── bin/ollama                 # pre-installed Ollama binary
    ├── lib/ollama/                # CUDA libs
    └── ollama_data/models/        # pre-loaded model cache (102 blobs)

/tmp/
└── aegis-job-<JOBID>/             # per-job ephemeral
    ├── neo4j-data/                # Neo4j data dir
    └── scratch/                   # any fast temp I/O

/home/paulinho/
├── .aegis_env                     # secrets, mode 600
└── .ssh/                          # SSH keys
```

## Lifecycle discipline

- `~/aegis-kg` is on NFS (no purge). Code and committed data survive
  indefinitely. This is safe for the repo, venv, and pip cache.
- `/projects/F202512235CPCAA1/CyberMetric_Deucalion/ollama_data/models` is
  persistent (not purged). The pre-loaded model cache lives here permanently.
- `/tmp` is per-job. Anything written here is lost when the job ends. Use a
  `trap` in the `sbatch` script to copy results out before exit:
  ```bash
  trap 'cp -r /tmp/aegis-job-$JOBID/results ~/aegis-kg/results/$JOBID/' EXIT
  ```
- `/home/paulinho` survives but is for config only. Don't accumulate large
  files there.

## Network filesystems in job scripts

- Use `~/aegis-kg` as the project root in job scripts. Do not assume
  `$WORK` or `$SCRATCH` exist.
- For ephemeral I/O, use `/tmp/aegis-job-$JOBID/`. Create it at job start:
  ```bash
  JOB_TMP="/tmp/aegis-job-$JOBID"
  mkdir -p "$JOB_TMP"/{neo4j-data,scratch}
  ```
- `sbatch` reads the script from the submit dir, so the script can live
  on NFS and still be submitted from anywhere.
- For very heavy I/O inside the job, prefer `/tmp` (local node storage).
