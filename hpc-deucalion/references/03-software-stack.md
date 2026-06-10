# 03 — Software Stack: Lmod, Python, CUDA, Ollama

## Lmod

Deucalion uses **Lmod**. The commands are:

```bash
module avail                    # list all available modules
module avail python             # filter by name
module show python/3.11.3-GCCcore-12.3.0   # inspect a module
module list                     # what is currently loaded
module load python/3.11.3-GCCcore-12.3.0  # load
module unload python            # unload
module purge                    # unload everything
```

Lmod is hierarchical and conflict-aware: loading a newer Python may
unload the old one. `module save default` and `module restore default`
let you pin a "default" set in `~/.lmod.d/default`.

**Login shell note:** On login nodes, `module load` requires a login
shell. Use `bash -lc` when invoking Python through ssh:

```bash
ssh paulinho@login.deucalion.macc.fccn.pt \
  'bash -lc "module load Python/3.11.3-GCCcore-12.3.0 && python --version"'
```

In `sbatch` scripts, modules load normally (the shell is already a
login shell).

## Python

The project requires **Python 3.11+**. The available module is:

```
Python/3.11.3-GCCcore-12.3.0
```

Always create a **per-project** virtualenv inside the project directory
(on NFS at `~/aegis-kg`), not a shared venv on `$HOME`.

**CRITICAL:** Use `--system-site-packages`. EasyBuild dependencies
live outside the venv and must be accessible.

```bash
module load Python/3.11.3-GCCcore-12.3.0
cd ~/aegis-kg
python -m venv --system-site-packages .venv
source .venv/bin/activate
pip install --upgrade pip wheel
```

## Dependencies (filter llama-cpp-python)

**CRITICAL:** `llama-cpp-python` does NOT compile on Deucalion (no
cmake/gcc on venv path). Filter it out before installing:

```bash
grep -v 'llama-cpp-python' requirements.txt > /tmp/req-deucalion.txt
pip install -r /tmp/req-deucalion.txt
# If any other C-extension package fails, see "Compilers" below.
```

## CUDA / GPU modules

```bash
module avail cuda
module avail cudnn
```

The Ollama module `ollama/0.20.3-GCCcore-14.2.0-CUDA-12.8.0` brings
CUDA 12.8 transitively. If you need CUDA outside of Ollama, load a
matching module. Loading the wrong CUDA version is the most common cause
of `libcudart.so: cannot open shared object file`.

## Compilers

The project ships pure Python; you should not need GCC/MPI. But some
packages ship C extensions. If a pip install fails for a C-extension
package (other than `llama-cpp-python`, which must be filtered out):

```bash
module load foss/2023a
pip install -r /tmp/req-deucalion.txt
```

**llama-cpp-python does NOT build on Deucalion** (no cmake/gcc on venv
path). Always filter it out of requirements.txt.

## Ollama -- pre-installed binary

Deucalion has Ollama pre-installed at:

```
/projects/F202512235CPCAA1/CyberMetric_Deucalion/bin/ollama
```

To use it in a job script (or login shell):

```bash
export PATH="/projects/F202512235CPCAA1/CyberMetric_Deucalion/bin:$PATH"
export LD_LIBRARY_PATH="/projects/F202512235CPCAA1/CyberMetric_Deucalion/lib/ollama:$LD_LIBRARY_PATH"
export OLLAMA_MODELS="/projects/F202512235CPCAA1/CyberMetric_Deucalion/ollama_data/models"
ollama --version
```

Alternative (module):

```bash
module load ollama/0.20.3-GCCcore-14.2.0-CUDA-12.8.0
```

The pre-installed binary is preferred -- it matches the pre-loaded model
cache. Do NOT run `ollama pull` inside AEGIS-KG jobs; models are
already present at the path above (102 blobs).

## Containers (Apptainer / Singularity)

Some sites do not allow Docker. Deucalion may offer **Apptainer**
(formerly Singularity). For AEGIS-KG you typically do not need a
container (pip + venv is enough). For Langfuse self-hosting you may
want one. If so:

```bash
module load apptainer
apptainer pull docker://langfuse/langfuse:3
apptainer run langfuse_3.sif
```

**Do not** use `docker` on HPC unless you have confirmed the site
permits it. Most do not.

## What you do NOT need

- `conda` / `mamba` -- discouraged on HPC (huge, hard to share, conflicts
  with system Python). Use `venv` unless the user asks.
- `pip install --user` -- pollutes `$HOME` and is hard to clean. Use venv.
- `poetry`, `uv` -- fine, but not required; the project uses plain
  `pip` + `requirements.txt`.
