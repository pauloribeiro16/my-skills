# 04 -- Environment Setup: venv, PYTHONPATH, .env, pip

## Goal

Recreate the AEGIS-KG dev environment on Deucalion inside a
project-local venv on NFS (`~/aegis-kg`), with environment variables
loaded from a file (not committed to git).

## 1. Transfer repo (NOT `git clone`)

HTTPS `git clone` fails (needs auth). SSH clone needs the key on the
cluster. Use tar+scp instead:

```bash
# On workstation:
cd ~/projects/aegis-kg
tar --exclude='.venv' --exclude='__pycache__' --exclude='*.pyc' \
    -czf /tmp/aegis-kg.tgz .
scp /tmp/aegis-kg.tgz paulinho@login.deucalion.macc.fccn.pt:

# On Deucalion (login node):
ssh paulinho@login.deucalion.macc.fccn.pt
cd ~
tar xzf aegis-kg.tgz
cd aegis-kg
```

## 2. Modules

```bash
module purge
module load Python/3.11.3-GCCcore-12.3.0
```

If `module load` fails inside an `ssh` session, use a login shell:

```bash
ssh -t paulinho@login.deucalion.macc.fccn.pt \
  'bash -lc "module load Python/3.11.3-GCCcore-12.3.0 && python --version"'
```

## 3. Virtualenv (with --system-site-packages)

```bash
cd ~/aegis-kg
python -m venv --system-site-packages .venv
source .venv/bin/activate
which python                       # should resolve inside .venv
python --version                   # 3.11.3
pip install --upgrade pip wheel
```

## 4. Dependencies (filter llama-cpp-python)

```bash
export PIP_CACHE_DIR=~/aegis-kg/.pip-cache
mkdir -p "$PIP_CACHE_DIR"

# CRITICAL: llama-cpp-python fails to compile on Deucalion (no cmake/gcc in venv)
grep -v 'llama-cpp-python' requirements.txt > /tmp/req-deucalion.txt
pip install -r /tmp/req-deucalion.txt
pip install pydantic pydantic-settings
```

If any other C-extension package fails, load `module load foss/2023a`
BEFORE `pip install`.

## 5. .env file

The project reads env vars via `python-dotenv` (`core/env.py`). On a
workstation you have `aegis-kg/.env` (gitignored). On Deucalion, put it
outside the repo (so different jobs / different users can swap) and
source it from the job script.

```bash
# /home/$USER/.aegis_env   (mode 600, never committed)
export NEO4J_PASSWORD='...'
export OLLAMA_HOST='http://cn01:11434'
export NEO4J_HTTP_URL='http://cn01:7475'
export NEO4J_BOLT_URL='bolt://cn01:7688'
export LANGFUSE_ENABLED='false'

# HPC: Ollama paths
export OLLAMA_BIN="/projects/F202512235CPCAA1/CyberMetric_Deucalion/bin"
export OLLAMA_MODELS="/projects/F202512235CPCAA1/CyberMetric_Deucalion/ollama_data/models"
```

Or use a **template** (`aegis-kg/.env.deucalion.example`) that the user
copies to `~/.aegis_env` and edits.

**Important:** the project's `core/env.py` reads `aegis-kg/.env` from
`os.path.dirname(__file__)/../.env` (or similar). If you keep the env
elsewhere, you must `export $(grep -v '^#' ~/.aegis_env | xargs)` from
the job script **before** the Python process starts.

## 6. PYTHONPATH

```bash
export PYTHONPATH=.
```

This works on Deucalion too -- but it must be set **after** the venv
activation (because `PYTHONPATH` inside an active venv usually already
contains the right paths). Use either:

```bash
source .venv/bin/activate
export PYTHONPATH="$PWD:$PYTHONPATH"
```

## 7. Smoke test

```bash
source .venv/bin/activate
export PYTHONPATH="$PWD:$PYTHONPATH"
python -c "from core.env import load_env; load_env(); print('env OK')"
python -m py_compile core/agent/graph/nodes.py
ollama list
```

All three should pass without errors. `ollama list` verifies that the
pre-loaded models are visible (you do not need to pull). If `core.env`
cannot find `.env`, the project **should not crash** -- defaults are
read from environment. Verify by inspecting `core/env.py`.

## 8. Common pitfalls

| Pitfall | Fix |
|---------|-----|
| `ModuleNotFoundError: No module named 'core'` | `export PYTHONPATH="$PWD"` |
| `pip` installs into system Python | Activate `.venv` first; check `which pip` |
| `pip install` extremely slow | Use `PIP_CACHE_DIR` and pre-built wheels |
| `venv` created with wrong Python version | `module load Python/3.11.3-GCCcore-12.3.0` BEFORE `python -m venv` |
| `dotenv` not loading | `python -c "from core.env import load_env; load_env()"` and inspect output |
| CUDA library missing | `module load` matching the driver version (see `03-software-stack.md`) |
| `llama-cpp-python` fails to compile | `grep -v 'llama-cpp-python' requirements.txt > /tmp/req.txt && pip install -r /tmp/req.txt` |
| `module load` fails in ssh | Use `bash -lc` for login shell: `ssh -t ... 'bash -lc "module load ..."'` |
| venv missing packages | Recreate with `--system-site-packages` |
| `git clone https` fails | Use tar+scp (see section 1) |
