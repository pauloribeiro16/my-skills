# Fresh-Context Evaluator Reference

The builder shouldn't grade its own work. After each feature, a separate agent with **no Write/Edit tools** grades the work from a context window that **never saw the build**.

## Core Principle

```
WRONG (self-evaluation trap):
  Generator builds code
  Generator grades own code → "Looks good!" (biased)

CORRECT (fresh-context):
  Generator builds code (context A)
  Evaluator grades code (context B, never saw build)
  → Independent verdict
```

The evaluator cannot be socially engineered by the generator. It receives only:
- The **artifact** (diff, files, screenshots)
- The **contract** (fixed rubric)

It does NOT receive:
- The generator's reasoning trace
- The generator's scratch notes
- The generator's self-assessment

## Why This Works

Agents will rationalize their own output. A standalone evaluator tuned for skepticism is far more tractable than making a generator critical of its own work. Once external feedback exists, the generator has something concrete to iterate against.

### The Self-Evaluation Trap

Models can identify problems in their own work but then rationalize them away. A structurally separate evaluator, tuned for skepticism, cannot be talked out of its findings.

```
Generator: "I used a global variable but it's fine because..."
Evaluator (fresh context): "Global state causes race condition. FAIL."
```

## Evaluator Configuration

### Tools

| Tool | Allowed? | Why |
|------|----------|-----|
| Read | ✅ | Must read artifact + contract |
| Bash (read-only) | ✅ | Run validation commands, read logs |
| Write | ❌ | Cannot modify artifact it's grading |
| Edit | ❌ | Cannot modify artifact it's grading |
| Task (subagent) | ❌ | Cannot delegate grading |

### Context Isolation

```
Generator session (context A):
  - Sees the build happen
  - Has scratch notes, failed attempts
  - Knows WHY each decision was made

Evaluator session (context B):
  - Cold start, fresh window
  - Only artifact + contract
  - No memory of generator's reasoning
```

The evaluator receives the artifact and the contract, **not the generator's transcript**.

## Evaluation Flow

```
1. Generator finishes implementation
   └─ Writes CONTRACT.json (passes fields still false)
   └─ Writes evidence files (test_output.log, screenshots)

2. Evaluator invoked (FRESH context, no Write/Edit)
   └─ Reads CONTRACT.json (the rubric)
   └─ Reads evidence files (opened via Read tool)
   └─ Runs validation commands (read-only Bash)
   └─ Grades each criterion

3. Evaluator returns:
   └─ PASS (all MUST criteria = true)
   └─ NEEDS_WORK (any MUST false, with specific findings)
```

## Verdict: PASS / NEEDS_WORK

Anthropic uses `PASS` / `NEEDS_WORK`, **not** `PASS` / `FAIL`.

```
PASS:
  - All MUST criteria: passes=true
  - >=50% SHOULD criteria: passes=true
  - No critical regressions

NEEDS_WORK:
  - Any MUST criterion: passes=false
  - <50% SHOULD criteria: passes=true
  - Returns SPECIFIC findings (file:line, exact behavior)
```

### Why NEEDS_WORK not FAIL?

`FAIL` implies finality. `NEEDS_WORK` signals iteration. The generator receives the findings and fixes them in the next cycle.

## Calibration

An uncalibrated evaluator is a liability. Without tuning, LLM-based evaluators approve mediocre output.

### Calibration Protocol

1. Run evaluator against known-good examples → should return PASS
2. Run evaluator against known-bad examples → should return NEEDS_WORK
3. Identify where judgment diverges from correct verdict
4. Update evaluator prompt to enforce skepticism at failure points

### Known Failure Modes

| Failure Mode | Description | Mitigation |
|--------------|-------------|-------------|
| Self-enhancement | Evaluator favors output it "authored" | Fresh context, no generator transcript |
| Position bias | Evaluator favors first-seen option | Fixed rubric order |
| Criteria drift | Evaluator refines criteria while grading | Pre-committed rubric (contract) |
| Leniency | Evaluator too generous | Calibration examples |

## Integration with Skill

- **Default-FAIL contract**: `references/json-contract-format.md`
- **Upfront negotiation**: Evaluator reviews contract BEFORE code (see `references/contract-workflow.md`)
- **Parallel execution**: Multiple evaluators run in parallel (one per sprint in group)
- **Correction loop**: NEEDS_WORK → Generator fixes → Evaluator re-grades

## Anthropic's Finding

> "The evaluator remains load-bearing even with our most capable model. The self-evaluation trap persists across model generations. Sprint decomposition and context resets may become optional as models improve. Audit periodically."

**Audit checklist:**
- [ ] Is evaluator still catching real issues?
- [ ] Can generator self-scope reliably?
- [ ] Should sprint construct be removed for this model?
- [ ] Are calibration examples still valid?
