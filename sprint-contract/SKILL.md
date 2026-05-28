---
name: sprint-contract
description: "Use before any implementation with 3+ file changes or complex tasks. Creates a structured contract with done criteria, validation commands, and quality dimensions. Supports phased goal decomposition for large objectives into iterative, smaller sprints. Inspired by Anthropic harness design."
---

# Sprint Contract Skill

Creates a structured implementation contract before coding. Based on Anthropic's generator-evaluator sprint negotiation pattern.

## When to Activate

- Tasks with 3+ file changes
- Complex features requiring multiple steps
- Large goals that may need phased decomposition
- Any implementation that needs validation
- When unsure about scope or acceptance criteria

## Trials

Non-deterministic agents (LLM-based) produce different outputs on each run. To account for variance, contracts support **pass@k** evaluation: run the same task *k* times and measure how many trials pass.

- **Default:** `trials: 3` in the contract header
- A criterion passes if it succeeds in ≥1 of k trials (pass@k)
- For deterministic changes (refactors, config), `trials: 1` is sufficient

Example contract header:

```yaml
trials: 3
pass_threshold: 2/3
```

## Phased Goal Decomposition

When the user presents a large goal, the Planner may decompose it into smaller, iterative, and phased objectives. This is the **Phased Goal Decomposition** workflow.

### When to Decompose

The Planner should ask the user if they want to decompose when **any** of the following criteria are met:

| Criterion | Description | Example |
|-----------|-------------|---------|
| **C1** | Goal describes multiple distinct functionalities | "Create auth system + dashboard + API" |
| **C2** | Mentions 3+ different components/architectures | "Frontend + Backend + Database + Cache" |
| **C3** | Requires changes to 5+ files (estimated) | "Change schema, models, controllers, views, tests" |
| **C4** | Uses sequence connectors | "First X, then Y, finally Z" |
| **C5** | Involves non-trivial architectural decisions | "Choose between microservices or monolith" |

> **Max phases:** 5-7. More than that creates excessive overhead.

### Decomposition Workflow

```
1. Planner analyzes goal → checks criteria C1-C5
   └─ If NONE match → create single CONTRACT.md (skip to normal workflow)

2. If ANY match → ask user via question tool:
   "This goal seems large. Do you want to decompose it into
    multiple phases with separate contracts?"

3. If NO → create single CONTRACT.md

4. If YES → Planner asks questions via question tool:
   a) Confirm the final objective
   b) Identify dependencies between parts
   c) Define implementation order
   d) Estimate files per phase

5. Planner generates GOAL_DECOMPOSITION.md

6. User approves decomposition (1 round)

7. Planner creates N CONTRACT.md (one per phase)
   - Each contract: specific phase with limited scope
   - Contract N+1 references previous phase as dependency

8. User approves ALL contracts at once

9. Sequential execution:
   For each phase (1..N):
     a) Launch Executor subagent for CONTRACT-phase-N.md
     b) Launch code-reviewer subagent to validate
     c) If PASS → update GOAL_DECOMPOSITION.md
     d) If FAIL after 3 attempts → STOP, ask user
     e) If user says "continue" → next phase

10. When all phases PASS:
    - Update QUALITY_LOG.md with full summary
    - Run Harness Audit if this is the 5th sprint
```

### Contracts in Phased Mode

Each phase gets its own contract. Contracts are "guard rails" — they define the WHAT (acceptance criteria), not the HOW (implementation). The Executor subagent has freedom to choose how to implement within the criteria.

### Integration with Existing Workflows

- **Saturation Detection:** Applies per phase. If 3+ consecutive phases score 100%, increase complexity.
- **Harness Audit:** Runs after completing the full goal (counts as 1 sprint).
- **Calibration Log:** Records divergences per phase.
- **Quality Log:** Entry per phase + overall goal summary.

## Contract Workflow

```
1. Planner writes CONTRACT.md (from template)
2. User approves (max 3 negotiation rounds)
3. Executor reads CONTRACT.md
4. Executor implements criteria sequentially
5. code-reviewer verifies each criterion
   - If FAIL → Executor fixes → code-reviewer re-checks (max 3)
   - If still FAIL after 3 → STOP and ask user
6. After all PASS → code-reviewer appends to QUALITY_LOG.md
```

## Contract Template

Copy from: `.opencode/skills/sprint-contract/templates/CONTRACT.md`

Or use the embedded version below:

```markdown
# CONTRACT — [Feature Name]
**Date:** YYYY-MM-DD
**Planner:** [name]
**Status:** DRAFT → NEGOTIATING → APPROVED → IMPLEMENTING → VALIDATED

## Trials
`trials: 3` (default)

## Scope
[What files change and why]

## Output Criteria (what was produced)
| # | Criterion | Weight | Result |
|---|-----------|--------|--------|
| 1 | [testable, binary pass/fail] | MUST | — |
| 2 | [testable, binary pass/fail] | MUST | — |
| 3 | [testable, binary pass/fail] | SHOULD | — |

## Outcome Criteria (system state after)
| # | Criterion | Weight | Result |
|---|-----------|--------|--------|
| 1 | [system state check] | MUST | — |
| 2 | [system state check] | SHOULD | — |

### Scoring Rules
1. MUST gate: any MUST fails → FAIL
2. SHOULD gate: <50% pass → FAIL
3. NICE: bonus only
4. Score: (passed / total) × 100%

## Validation Commands
| What | Command | Expected |
|------|---------|----------|
| File compiles | `python -m py_compile [path]` | 0 |
| Tests pass | `pytest [path] -v` | PASS |

## Quality Dimensions
| Dimension | Threshold |
|-----------|-----------|
| Correctness | 100% |
| Pattern Compliance | ≥3/4 |
| No Regressions | 100% |
| Data Integrity | 100% |

## Files to Change
| File | Action |
|------|--------|
| `src/x.py` | create/modify |

## Correction Loop
- Max 3 cycles per criterion
- After 3 failures: STOP and ask user
```

## Negotiation Rounds

| Round | Action |
|-------|--------|
| 1 | Planner writes initial contract → presents to user |
| 2 | User requests changes (if any) |
| 3 | Final changes → user approves |

Max 3 rounds. After that, present final version for approval or abandonment.

## Good vs Bad Criteria

Each criterion must be TESTABLE — pass or fail, not subjective.

### Severity Levels

| Level | Meaning | Examples |
|-------|---------|----------|
| **MUST** | Blocking — must pass for contract to succeed | `File compiles without errors`, `All tests pass` |
| **SHOULD** | Important — contract succeeds but flags improvement | `Follows naming convention`, `Code coverage ≥80%` |
| **NICE** | Optional — tracked but never blocks | `Includes docstrings`, `Error messages are user-friendly` |

### Examples

| Good ✅ | Bad ❌ |
|--------|--------|
| `File compiles without errors` | `Code looks good` |
| `Function X accepts a, b, c and returns dict` | `Function works correctly` |
| `All tests in test_file.py pass` | `Tests pass` |

## Before Creating Contract

1. Read relevant AGENTS.md files (root + sub-AGENTS.md)
2. Read `execution/CALIBRATION_LOG.md` for historical divergences
3. Review `execution/QUALITY_LOG.md` — if 3+ consecutive 100%, raise the bar
4. Check Criterion Effectiveness table for CANDIDATE FOR REMOVAL items
5. Understand existing code patterns
6. Identify all files that need changes
7. Think about how to verify each change
8. If Calibration Log has OPEN items → address them in new criteria

## After Contract Approved

**MANDATORY: Always launch subagents. NEVER implement or verify yourself.**

1. **MANDATORY: Launch Executor subagent** (`task(subagent_type="general")`) to read CONTRACT.md and implement all criteria sequentially
2. Executor runs trials (if `trials > 1` specified)
3. Results recorded with pass@k metric
4. **MANDATORY: Launch code-reviewer subagent** (`task(subagent_type="general")`) to verify each criterion independently
5. code-reviewer checks partial credit scoring (SHOULD/NICE criteria contribute to overall score but don't block)
6. If FAIL → launch Executor subagent again to fix → launch code-reviewer subagent again to re-check (max 3)
7. If user disagrees with code-reviewer → record divergence in `execution/CALIBRATION_LOG.md`
8. Update Criterion Effectiveness table in Quality Log
9. After all pass → Update Quality Log
10. **Commit validated sprint** (see Git Integration section for details)
11. If this is the 5th sprint → run Harness Audit (see below)
12. If phased goal and all phases PASS → follow merge flow in Git Integration → Branch Management

**Why subagents:** Separation of concerns — the Planner orchestrates, the Executor implements, the code-reviewer verifies. This prevents self-evaluation bias (agents tend to approve their own work).

## Git Integration

### Commit Strategy

- **Planner makes commits** (not Executor)
- **One commit per validated sprint**
- Only commits when code-reviewer gives **PASS**
- If **FAIL** → STOP, no commit

### Commit Message Format

```
feat(scope): description — phase N/M [PASS: X%]

- Contract: CONTRACT-phase-N.md
- Files: list of changed files
- Score: X% (MUST: Y/Z, SHOULD: Y/Z)
- Reviewer: [agent]
```

### Branch Management

- **Single contract:** commit to current branch (master/main)
- **Phased goal:** create branch `sprint/nome-do-objetivo`
- All phases commit to this branch
- After all PASS: ask user "Merge?"
- User approves → merge to main → delete branch
- If merge error → keep branch for debug

### Security Hooks

- Pre-commit hooks run before each commit
- If secrets detected → commit blocked
- Executor must clean before retry

### Integration with Workflow

The Git Integration is embedded into the contract workflow:

- **Single contract:** after step 10 (commit), contract is complete
- **Phased goal:** after each phase PASS → commit to sprint branch; after all phases PASS → follow merge flow

## Saturation Detection

If 3+ consecutive contracts score 100% on all criteria, the evaluation has saturated — there is no signal for improvement. This means:

- Criteria are too easy and need to be made harder
- Add SHOULD/NICE criteria that stretch quality
- Introduce adversarial test cases or edge-case coverage
- Consider increasing the scope of contracts

The Quality Log (`execution/QUALITY_LOG.md`) tracks historical scores. Review it before writing a new contract. If recent entries show consistent 100%, raise the bar.

## Evaluator Calibration

Before writing a new contract, the Planner should read `execution/CALIBRATION_LOG.md` and adjust criteria based on historical divergences.

### Calibration Workflow

```
1. code-reviewer reviews → records result in Quality Log
2. If user disagrees with verdict → user flags divergence
3. code-reviewer appends entry to CALIBRATION_LOG.md
4. Before next contract → Planner reads CALIBRATION_LOG
5. Planner adjusts criteria (strengthen/relax/simplify)
6. Run 3 sprints → mark action as VALIDATED if no recurrence
```

### When to Calibrate

- After any sprint where user manually overrides code-reviewer
- Every 5 sprints as routine review
- When Quality Log shows systematic bias (all PASS or all FAIL)

### Calibration Actions

| Divergence Type | Action |
|-----------------|--------|
| False positive (reviewer PASS, user FAIL) | Strengthen criterion or add validation command |
| False negative (reviewer FAIL, user PASS) | Simplify criterion or downgrade MUST → SHOULD |
| Same criterion fails 3+ times | Consider if criterion is load-bearing or noise |

---

## Harness Audit

Every component in the harness encodes an assumption about what the model cannot do on its own. Audit periodically to find overhead.

### Audit Workflow

```
1. Read Quality Log — last 5 sprints
2. Review Criterion Effectiveness table
3. Identify components that never caught issues
4. Remove one component from next contract
5. Track if quality drops
6. If no drop → remove permanently
7. If quality drops → restore component
```

### Effectiveness Classification

| Fail Rate | Classification | Action |
|-----------|----------------|--------|
| >30% | CRITICAL | Keep — load-bearing |
| 10-30% | USEFUL | Keep — catches real regressions |
| 1-10% | MARGINAL | Consider merging with another criterion |
| 0% (5+ sprints) | CANDIDATE FOR REMOVAL | Test removing in next sprint |

### Audit Rules

- Remove ONE component at a time (never multiple)
- Run at least 3 sprints before declaring a component unnecessary
- If a removed component was actually needed, restore immediately
- Record all audit decisions in CALIBRATION_LOG.md

---

## Templates Available

| Template | Path |
|----------|------|
| Contract | `.opencode/skills/sprint-contract/templates/CONTRACT.md` |
| Goal Decomposition | `.opencode/skills/sprint-contract/templates/GOAL_DECOMPOSITION.md` |
| Quality Log | `.opencode/skills/sprint-contract/templates/QUALITY_LOG.md` |
| Calibration Log | `execution/CALIBRATION_LOG.md` |
| Session State | `.opencode/skills/sprint-contract/templates/SESSION_STATE.md` |
