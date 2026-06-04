---
name: eval-runner
description: "Use when running evaluation tasks. Ensures progressive eval (1 task -> 2-3 -> max 5), proper trial count, and correct result interpretation. Prevents timeout issues with large batches."
---

# Eval Runner Skill

Runs evaluation tasks correctly using progressive batching. Prevents timeout issues.

## When to Activate

- Running any evaluation task
- Before executing the eval harness
- When checking eval results
- When troubleshooting low scores

## Progressive Eval Rule (CRITICAL)

**NEVER run all tasks at once.**

| Phase | Tasks | Why |
|-------|-------|-----|
| Step 1 | 1 task | Verify setup works |
| Step 2 | 2-3 tasks | Check consistency |
| Step 3 | Max 5 tasks | Standard batch |
| Full suite | Only with explicit approval | Timeout risk |

## Command Templates

### Single Task (always start here)
```bash
PYTHONPATH=. python [eval_script] \
  --config [config_path] \
  --task T001 \
  --trials 1 \
  --verbose
```

### Small Batch (2-5 tasks)
```bash
PYTHONPATH=. python [eval_script] \
  --config [config_path] \
  --trials 1 \
  --verbose
```

### Single Task with Specific ID
```bash
PYTHONPATH=. python [eval_script] \
  --config [config_path] \
  --task T017 \
  --trials 1 \
  --verbose
```

## Environment Setup

```bash
# Activate venv
source [path/to/venv]/bin/activate

# Set PYTHONPATH
export PYTHONPATH=.

# Verify config
cat [config_path] | grep -E "connection|model"
```

## Understanding Results

| Score | Meaning | Action |
|-------|---------|--------|
| 0.0 | No data loaded OR wrong config | Check data, check connection |
| 0.5-0.7 | Partial match | Review expected vs actual |
| 0.8-1.0 | Good match | Task passed |
| timeout | Model not responding | Reduce batch size |

## Evaluation Flow

1. **Pre-check**: Verify data loading succeeded
2. **Run single task**: `T001 --trials 1`
3. **If pass**: Run 2-3 more tasks
4. **If still passing**: Run up to 5
5. **If fail**: Debug before continuing

## Trial Count

| Situation | Trials |
|-----------|--------|
| Quick smoke test | 1 |
| Standard evaluation | 1 |
| Investigating intermittent failure | 3 |
| Final validation | 1 |

## Troubleshooting Low Scores

| Symptom | Check |
|---------|-------|
| All scores 0.0 | Data loaded? Connection working? |
| Some scores 0.0 | Specific tasks failing? |
| Timeout | Batch too large? Model overloaded? |
| Wrong answers | Config path correct? Dataset property set? |

## Output Format

```
## Eval Results

**Config:** [config_name]
**Tasks run:** [N]
**Passed:** [M]
**Failed:** [K]

### Per-Task Results
| Task | Score | Notes |
|------|-------|-------|
| T001 | 1.0 | PASS |
| T002 | 0.0 | FAIL — no data |
| T003 | 0.8 | Partial |

**Next step:** [recommendation]
```

## Safety Limits

- Max 5 tasks per batch
- Max 3 trials per task
- Always start with 1 task
- If 3 consecutive timeouts: STOP and report
