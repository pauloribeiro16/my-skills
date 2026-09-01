# 01 — Access: SSH, Login Nodes, 2FA

## SSH

```bash
# Basic SSH (no MFA)
ssh paulinho@login.deucalion.macc.fccn.pt

# With SSH key registered at the portal
ssh -i ~/.ssh/id_ed25519 paulinho@login.deucalion.macc.fccn.pt

# If 2FA is required: see "Two-factor authentication" below
```

Useful SSH options for working inside jobs or on slow links:

```bash
# Keep alive (helps with long squeue polling sessions)
ssh -o ServerAliveInterval=60 paulinho@login.deucalion.macc.fccn.pt

# X11 forwarding (rarely useful on HPC; prefer SSH tunnels)
ssh -X paulinho@login.deucalion.macc.fccn.pt
```

## Login nodes

There is typically **one canonical login node** and possibly **a small
pool**. They are interchangeable from a job-submission perspective. To see
the live set:

```bash
# After login, on a login node:
sinfo -p login 2>/dev/null || sinfo -o "%N %T %P" | head
```

**Rules on login nodes:**

- No long-running processes (>10 min CPU, >2 GB RAM triggers the site
  watchdog).
- No neo4j, no ollama serve, no docker, no heavy compilations.
- OK: `git`, `vim`, `cat`, `ls`, `module`, `sbatch`, `squeue`, `sacct`,
  small `pip install` of pre-built wheels.

## Two-factor authentication (if required)

Two common patterns on Deucalion-style clusters:

1. **TOTP + SSH key.** You provide a TOTP code in addition to the SSH key
   (e.g., as a `SSH_OTP` env var or via a wrapper).
2. **TOTP on the web portal only.** SSH key is enough for `ssh`; the
   portal prompts for TOTP.

If TOTP is required and you do not have it configured, **stop and ask the
user** — this is an account-recovery flow, not something to improvise.

## SSH tunnels for service access

If you run Neo4j / Ollama on a compute node, you typically reach it from
your laptop (or from another compute node) via an SSH tunnel. SLURM
allocates compute node hostnames dynamically.

```bash
# On the login node, get the compute node hostname of a running job
squeue -j <JOBID> -o "%N" -h
# Returns: cn01

# On your laptop, open a tunnel
ssh -L 17475:cn01:7475 -L 17688:cn01:7688 paulinho@login.deucalion.macc.fccn.pt -N
# Now neo4j on cn01 is reachable from your laptop at localhost:17475
```

For temporary debugging only — for production, use compute-node-to-compute-node
direct networking inside a job allocation (`srun --jobid` or a job step).

## VS Code / Remote SSH

VS Code's "Remote - SSH" extension works against Deucalion login nodes.
Add to `~/.ssh/config`:

```
Host deucalion
    HostName login.deucalion.macc.fccn.pt
    User <USER>
    IdentityFile ~/.ssh/deucalion_ed25519
    ServerAliveInterval 60
```

**Caveat:** VS Code will try to install its server on `$HOME`. If `$HOME`
is tiny (see `02-storage.md`), override the path:

```
Host deucalion
    ...
    RemoteCommand export VSCODE_AGENT_FOLDER=$HOME/.vscode-remote; $SHELL
```

or set the env var in your shell profile on the cluster.

## Direct intra-cluster access (compute → login)

Once you have an interactive allocation (`salloc`), you can `ssh` from the
compute node back to the login node to chain commands. This is sometimes
useful for the `git push` step inside a job.

```bash
# Inside an salloc shell:
ssh login
```
