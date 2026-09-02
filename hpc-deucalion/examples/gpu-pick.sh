#!/usr/bin/env bash
# gpu-pick.sh — recommend a SLURM partition/gres for an Ollama run.
#
# Reads the model tag (e.g. `granite4.2:30b`), looks up the parameter
# count from a small baked-in table (the AEGIS tags we've actually used),
# estimates VRAM (Q4_K_M + 32k ctx + 2 GB overhead), and suggests the
# smallest partition that fits — saving the 80GB queue for the (rare)
# workloads that need it.
#
# Usage:
#   ./examples/gpu-pick.sh granite4.2:30b            # recommendation only
#   ./examples/gpu-pick.sh granite4.2:30b --gres     # also prints #SBATCH lines
#   ./examples/gpu-pick.sh granite4.2:30b --live     # also runs sinfo (login node)
#
# If your tag is unknown, you can pass the param count explicitly:
#   ./examples/gpu-pick.sh mymodel 9b
# or it falls back to a best-effort parse of "<num>b" in the tag.

set -euo pipefail

# AEGIS-tag → parameters (B). Q4_K_M is Ollama's default quant; override
# with OLLAMA_QUANT if you know the model's actual quant differs.
TABLE='ornith:9b 9
phi4:14b 14
gemma3:4b 4
gemma3:1b 1
gemma3:270m 0.27
gemma4:26b 26
gemma4:e2b 2
gemma4:e4b 4
mistral:7b 7
ministral-3:8b 8
qwen3:0.6b 0.6
qwen3:1.7b 1.7
qwen3:4b 4
qwen3:8b 8
qwen3:14b 14
qwen3.5:27b 27
qwen3.5:9b 9
qwen3.8:27b 27
granite4.2:30b 30
muse-glimmer:30b 30
nemotron-3.5-lightning:30b 30
glm-4.7-flash:latest 10
gpt-oss:20b 20
gemma3n:e2b 2
gemma3n:e4b 4'

if [ $# -lt 1 ]; then
  echo "usage: $0 <model:tag> [--gres] [--live]" >&2
  echo "       e.g. $0 granite4.2:30b" >&2
  exit 2
fi

MODEL="$1"
shift
WANT_GRES=0
LIVE=0
for arg in "$@"; do
  case "$arg" in
    --gres) WANT_GRES=1 ;;
    --live) LIVE=1 ;;
  esac
done

# Look up params.
PARAMS=$(printf '%s\n' "$TABLE" | awk -v m="$MODEL" '$1==m{print $2}')
if [ -z "$PARAMS" ]; then
  # Best-effort: parse "<num>b" from the tag.
  NUM=$(echo "$MODEL" | grep -oE '[0-9]+(\.[0-9]+)?b' | head -1 | sed 's/b$//' || true)
  if [ -n "$NUM" ]; then PARAMS="$NUM"; fi
fi
if [ -z "$PARAMS" ]; then
  echo "⚠ unknown tag '$MODEL' — falling back to 'assume ≤ 14B (medium)'" >&2
  PARAMS=14
fi

# VRAM estimate: weights (Q4_K_M ≈ 0.6 GB/B) + KV (≈ 0.15 GB/B @ 32k ctx)
# + 2 GB overhead. Use `LC_ALL=C` so the comparison layer doesn't choke
# on locale-dependent decimal separators ("8,7" vs "8.7") when we
# pass the values back to awk below.
LC_ALL=C
export LC_ALL

V_WEIGHTS=$(awk -v p="$PARAMS" 'BEGIN { printf "%.1f", p*0.6 }')
V_KV=$(awk -v p="$PARAMS" 'BEGIN { printf "%.1f", p*0.15 }')
V_TOT=$(awk -v w="$V_WEIGHTS" -v k="$V_KV" 'BEGIN { printf "%.1f", w+k+2 }')

# Pick: 1×40GB if ≤36, 1×80GB if ≤72, else 2×80GB.
if awk -v t="$V_TOT" 'BEGIN { exit !(t<=36) }'; then
  PARTITION="dev-a100-40"
  GRES="gpu:a100:1"
  RATIONALE="fits 1× A100-40 (≈${V_TOT} GB) — frees the 80 GB queue"
elif awk -v t="$V_TOT" 'BEGIN { exit !(t<=72) }'; then
  PARTITION="dev-a100-80"
  GRES="gpu:a100:1"
  RATIONALE="needs 1× A100-80 (≈${V_TOT} GB)"
else
  PARTITION="dev-a100-80"
  GRES="gpu:a100:2"
  RATIONALE="needs 2× A100-80 (≈${V_TOT} GB) — Ollama splits layers within the node; never cross-node"
fi

echo "model:    $MODEL"
echo "params:   ${PARAMS}B (Q4_K_M, ctx=32k default)"
echo "VRAM:     ${V_TOT} GB (weights=${V_WEIGHTS}G + kv=${V_KV}G + 2G ovh)"
echo "→ PARTITION=$PARTITION --gres=$GRES"
echo "  $RATIONALE"

if [ "$WANT_GRES" = 1 ]; then
  echo ""
  echo "# sbatch directives to add:"
  echo "#SBATCH --partition=$PARTITION"
  echo "#SBATCH --gres=$GRES"
fi

if [ "$LIVE" = 1 ]; then
  if command -v sinfo >/dev/null 2>&1; then
    echo ""
    echo "### Free-state mix in $PARTITION (idle / mixed / allocated / reserved):"
    sinfo -p "$PARTITION" -h -o '%T' | sort | uniq -c | awk '{printf "  %s  %s\n",$2,$1}'
  else
    echo ""
    echo "### sinfo not available — run on the login node for a live snapshot."
  fi
fi
