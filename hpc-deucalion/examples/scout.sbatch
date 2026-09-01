#!/usr/bin/env bash
#SBATCH --job-name=aegis-scout
#SBATCH --account=<DEUCALION_ACCOUNT>
#SBATCH --partition=<DEUCALION_PARTITION>
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G
#SBATCH --time=00:10:00
#SBATCH --output=slurm-scout-%j.out
#SBATCH --error=slurm-scout-%j.err
#SBATCH --chdir=$WORK/aegis-kg

# ============================================================================
# scout.sbatch — Environment reconnaissance for AEGIS-KG on Deucalion.
#
# Run this FIRST, before any GPU job. It produces a report of:
#   - account / partition / QoS availability
#   - Python + CUDA + Ollama module availability
#   - GPU availability
#   - internet egress (to GitHub, PyPI, Langfuse Cloud)
#   - storage tiers (HOME / WORK / SCRATCH)
#
# Submit:
#   sbatch .opencode/skills/hpc-deucalion/examples/scout.sbatch
#
# Read the report:
#   cat slurm-scout-<JOBID>.out
# ============================================================================

set -uo pipefail

print_section() {
  echo ""
  echo "============================================================"
  echo "  $1"
  echo "============================================================"
}

print_kv() {
  local key=$1
  local val=${2:-"<unset>"}
  printf "  %-30s %s\n" "$key" "$val"
}

print_section "1. Identity"
print_kv "whoami"       "$(whoami 2>/dev/null || echo N/A)"
print_kv "hostname"     "$(hostname 2>/dev/null || echo N/A)"
print_kv "date"         "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
print_kv "SLURM_JOB_ID" "${SLURM_JOB_ID:-<not-in-job>}"
print_kv "SLURM_NODELIST" "${SLURM_NODELIST:-<not-in-job>}"

print_section "2. Storage tiers"
print_kv "HOME"    "${HOME:-<unset>}"
print_kv "WORK"    "${WORK:-<unset>}"
print_kv "SCRATCH" "${SCRATCH:-<unset>}"
for d in "$HOME" "$WORK" "$SCRATCH"; do
  if [[ -d "$d" ]]; then
    print_kv "  $d usage" "$(df -h "$d" 2>/dev/null | tail -1 | awk '{print $5 " used, " $4 " free"}')"
  fi
done

print_section "3. Project location"
print_kv "PWD"         "$PWD"
print_kv "AEGIS_KG"    "${AEGIS_KG_DIR:-$PWD}"
if [[ -d "$PWD/.venv" ]]; then
  print_kv "venv"        "present (good)"
else
  print_kv "venv"        "MISSING — create with: python -m venv .venv"
fi
if [[ -f "$HOME/.aegis_env" ]]; then
  print_kv "~/.aegis_env" "present (mode $(stat -c '%a' "$HOME/.aegis_env" 2>/dev/null || echo '?'))"
else
  print_kv "~/.aegis_env" "MISSING — create from .env.deucalion.example"
fi

print_section "4. SLURM account + QoS"
if command -v sacctmgr >/dev/null 2>&1; then
  sacctmgr show assoc user="$USER" 2>/dev/null | head -20
else
  echo "  sacctmgr not available"
fi

print_section "5. Partitions visible to me"
if command -v sinfo >/dev/null 2>&1; then
  sinfo -o "%P %a %D %G %l %t" 2>/dev/null
else
  echo "  sinfo not available"
fi

print_section "6. GPU availability"
if command -v sinfo >/dev/null 2>&1; then
  GPU_OUT=$(sinfo -p gpu -o "%P %N %G %D %t" 2>/dev/null || true)
  if [[ -n "$GPU_OUT" ]]; then
    echo "$GPU_OUT"
  else
    echo "  no GPU partition visible to your account"
  fi
else
  echo "  sinfo not available"
fi

print_section "7. Available Python modules"
if command -v module >/dev/null 2>&1; then
  module avail python 2>&1 | head -20
else
  echo "  module command not available — is this a login node?"
fi

print_section "8. Available CUDA modules"
if command -v module >/dev/null 2>&1; then
  module avail cuda 2>&1 | head -10
else
  echo "  module command not available"
fi

print_section "9. Ollama availability"
if command -v module >/dev/null 2>&1; then
  OLLAMA_MOD_OUT=$(module avail ollama 2>&1 || true)
  if [[ -n "$OLLAMA_MOD_OUT" ]] && ! echo "$OLLAMA_MOD_OUT" | grep -qi "no module"; then
    echo "$OLLAMA_MOD_OUT"
  else
    echo "  no ollama module — will install binary in job"
  fi
fi
if command -v ollama >/dev/null 2>&1; then
  print_kv "ollama binary" "$(ollama --version 2>&1)"
else
  print_kv "ollama binary" "not on PATH"
fi

print_section "10. Internet egress"
check_url() {
  local label=$1
  local url=$2
  if curl -sf --max-time 8 -o /dev/null "$url"; then
    echo "  OK   $label ($url)"
  else
    echo "  FAIL $label ($url)"
  fi
}
check_url "GitHub"         "https://github.com"
check_url "PyPI"           "https://pypi.org"
check_url "Langfuse Cloud" "https://cloud.langfuse.com"
check_url "Ollama registry" "https://ollama.com"

print_section "11. Required env vars"
for v in NEO4J_PASSWORD OLLAMA_HOST LANGFUSE_ENABLED LANGFUSE_BASE_URL LANGFUSE_PUBLIC_KEY LANGFUSE_SECRET_KEY; do
  val="${!v:-}"
  if [[ -n "$val" ]]; then
    print_kv "$v" "set (len=${#val})"
  else
    print_kv "$v" "MISSING"
  fi
done

print_section "12. GPU on this node (if allocated)"
if command -v nvidia-smi >/dev/null 2>&1; then
  nvidia-smi 2>&1 | head -20
else
  echo "  nvidia-smi not found — node has no GPU (this scout job is CPU-only)"
fi

print_section "=== SCOUT COMPLETE ==="
echo "Next steps:"
echo "  - If 'PWD' shows aegis-kg, env is good."
echo "  - If venv is MISSING, run: python -m venv .venv && source .venv/bin/activate"
echo "  - If ~/.aegis_env is MISSING, copy from .env.deucalion.example and edit."
echo "  - If 'GPU availability' shows IDLE nodes, submit test-ollama-gpu.sbatch."
echo "  - If 'Internet egress' shows FAIL, GPU jobs will work but Langfuse traces will be lost."
echo "  - If 'SLURM account' shows no rows, ask your PI for allocation."
