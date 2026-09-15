# Parallel Execution Reference

Sprint dependency graph analysis and parallel subagent dispatch.

## Core Concept

Not all sprints are sequential. When a pipeline has sprints that don't depend on each other, they can execute in parallel via subagents — reducing total implementation time.

```
BEFORE (sequential):
S1 → S2 → S3 → S4 → S5   [5 sprints, ~50 min]

AFTER (parallel where possible):
Group 0: S1               [5 min]
Group 1: S2, S3           [10 min] (parallel)
Group 2: S4               [10 min]
Group 3: S5               [5 min]
                           ~30 min total
```

## Dependency Graph Rules

### Building the Graph

For each sprint, ask:

1. **Does this sprint read/create files that another sprint modifies?**
2. **Does this sprint produce an output that another sprint consumes?**
3. **Does this sprint set up infrastructure that another sprint depends on?**

If YES to any → depends on that sprint.
If NO to all → independent, can run in parallel with others that are also independent.

### Graph Construction Algorithm

```
For each sprint S:
  S.dependencies = []

For each sprint S:
  For each sprint T where T ≠ S:
    If S reads files T writes → S.dependencies.add(T)
    If S uses output T produces → S.dependencies.add(T)
    If S needs infra T creates → S.dependencies.add(T)
    If T reads files S writes → T.dependencies.add(S)
    If T uses output S produces → T.dependencies.add(S)
    If T needs infra S creates → T.dependencies.add(S)
```

### Parallel Group Assignment

```
1. Find sprints with no dependencies → Group 0
2. Remove Group 0 from graph
3. Find sprints whose dependencies are all in Group 0 → Group 1
4. Repeat until all sprints assigned

Groups execute sequentially.
Sprints within a group execute in parallel.
```

## Scoped Git Discipline (NEW 2026-08-13)

In a parallel group, every git command MUST be path-scoped to the sprint's OWNED_FILES. This is the single most important rule to prevent the "baralham-se" symptom (agents seeing each other's changes when verifying "what did I change vs what was I supposed to change").

### Allowed ✅ (in parallel groups)

| Command | Purpose |
|---------|---------|
| `git status --short -- <OWNED_FILES>` | See what THIS sprint changed |
| `git diff HEAD -- <OWNED_FILES>` | See unstaged changes for THIS sprint |
| `git diff $BASE_COMMIT -- <OWNED_FILES>` | See THIS sprint's changes vs the group's baseline |
| `git diff --cached -- <OWNED_FILES>` | See staged changes for THIS sprint |
| `git add -- <OWNED_FILES>` | Stage ONLY this sprint's files |
| `git log -- <OWNED_FILES>` | History relevant to THIS sprint's files |
| `git show <sha> -- <OWNED_FILES>` | Inspect a specific commit's impact on THIS sprint |

### Forbidden ❌ (in parallel groups)

| Command | Why forbidden |
|---------|---------------|
| `git status` (bare) | Shows ALL sprints' changes — agent can't tell its own |
| `git diff` (bare) | Same — agent attributes others' changes to itself |
| `git add .` / `git add --all` / `git add -A` | Stages every sprint's changes — causes cross-commit pollution |
| `git commit -a` | Same as `git add --all` + commit |
| `git add -u` | Tracks all modifications, including other sprints' |

### Baseline verification template

Each Generator and Evaluator MUST verify its work only against the BASELINE_COMMIT, scoped to OWNED_FILES:

```bash
# What did THIS sprint change since the group started?
git diff $BASE_COMMIT -- <OWNED_FILES> | head -100

# Did I touch anything I shouldn't have?
git diff $BASE_COMMIT --stat -- . ':!<OWNED_FILES>'
# Expected: empty
```

If the second command returns non-empty, the agent has written outside its OWNED_FILES — STOP and report.

### Repository-wide commands (allowed when not in a parallel group)

When running serially (no parallel group active), the full-tree commands are fine: `git status`, `git diff`, `git add --all`. The discipline applies only when other sprints in the same group are still writing.

---

### Conflict Detection (HARD GATE — 2026-08-13)

Before launching parallel sprints, the planner MUST check for **file conflicts** based on OWNED_FILES (derived from each sprint's `files_to_change` in CONTRACT.json). Overlapping OWNED_FILES in the same group BLOCKS the group (not a warning).

```
For each pair (S, T) in same group:
  If S.OWNED_FILES ∩ T.OWNED_FILES ≠ ∅:
    BLOCK the group → force sequential for the conflicting pair
    → split into sub-groups by file domain, OR
    → sequence the conflicting sprints
```

| Conflict Type | Action |
|---------------|--------|
| Same file in OWNED_FILES of two sprints | **BLOCK the group, force sequential** |
| No overlap in OWNED_FILES | Parallel OK |
| Same file but read-only for one | Parallel OK (only one writes) |

**Why HARD GATE:** in the shared working tree, a `git add --all` at group end would sweep both sprints' changes into one commit, and parallel generators doing `git diff` to verify "what did I change" would see each other's changes too. Disjoint OWNED_FILES is the safe precondition.

## Pipeline Execution Template

```markdown
# Pipeline Execution — [Goal Name]

## Dependency Graph

| Sprint | Depends On | Parallel Group | Files |
|--------|-----------|----------------|-------|
| S1 | — | 0 | state.py, agent.py |
| S2 | S1 | 1 | nodes.py |
| S3 | S1 | 1 | prompts.py |
| S4 | S2, S3 | 2 | eval.py, judge.py |
| S5 | S4 | 3 | tests/test_all.py |

## Execution Plan

```
Group 0: [S1]
  └─ Generator(S1) → WAIT → Evaluator(S1) → Commit

Group 1: [S2, S3]  ← PARALLEL EXECUTORS, then PARALLEL REVIEWERS
  ├─ Generator(S2)  ┐
  ├─ Generator(S3)  ├─ WAIT ALL finish
  └────────────────┘
  ├─ Evaluator(S2)  ┐
  ├─ Evaluator(S3)  ├─ WAIT ALL finish
  └────────────────┘
  → Commit

Group 2: [S4]
  └─ Generator(S4) → WAIT → Evaluator(S4) → Commit

Group 3: [S5]
  └─ Generator(S5) → WAIT → Evaluator(S5) → Commit
```
```

## Parallel Dispatch Protocol

### ⚠️ CRITICAL RULE: Generator → Evaluator is ALWAYS Sequential

```
NEVER DO THIS:
  task(Generator, S1)
  task(Evaluator, S1)    ← WRONG! S1 code not ready yet
  task(Generator, S2)

ALWAYS DO THIS:
  task(Generator, S1)
  task(Generator, S2)    ← All Generators first
  ── WAIT ALL FINISH ──
  task(Evaluator, S1)
  task(Evaluator, S2)    ← All Evaluators after
  ── WAIT ALL FINISH ──
```

**Why:** Evaluators READ code. If code doesn't exist yet (Generator still writing), Evaluator has nothing to validate. Launching Evaluator before Generator finishes = guaranteed NEEDS_WORK or garbage validation.

**The two phases are:**
1. **EXECUTE** (write code) — can be parallel across sprints
2. **VALIDATE** (read code) — can be parallel across sprints, but ONLY after EXECUTE finishes

### Launching Parallel Sprints (UPDATED 2026-08-13)

```
For each group G in execution plan:
  ┌─────────────────────────────────────────────┐
  │ PHASE 0: BASELINE (planner, before launch)  │
  │                                             │
  │ 1. Record: BASE_COMMIT=$(git rev-parse HEAD) │
  │ 2. Derive OWNED_FILES per sprint from       │
  │    files_to_change in CONTRACT.json.        │
  │ 3. Conflict check: disjoint OWNED_FILES      │
  │    across G? If NO → BLOCK, force sequential.│
  │ 4. Pass to each Generator/Evaluator prompt:  │
  │    - BASE_COMMIT                              │
  │    - OWNED_FILES (pathspec list)             │
  │    - rule: "NEVER bare git diff/status/add"  │
  └─────────────────────────────────────────────┘
                     │
                     ▼
  ┌─────────────────────────────────────────────┐
  │ PHASE A: EXECUTE (write code)               │
  │                                             │
  │ 1. Launch ALL Generator subagents in G       │
  │    (each with OWNED_FILES + BASE_COMMIT)     │
  │ 2. WAIT for ALL Generators to complete       │
  │    ← DO NOT launch any Evaluator yet! →      │
  └─────────────────────────────────────────────┘
                     │
                     ▼
  ┌─────────────────────────────────────────────┐
  │ PHASE B: VALIDATE (read code)               │
  │                                             │
  │ 3. Launch Evaluator for EACH sprint          │
  │    (each with OWNED_FILES + BASE_COMMIT)     │
  │ 4. WAIT for ALL Evaluators to complete       │
  └─────────────────────────────────────────────┘
                     │
                     ▼
  ┌─────────────────────────────────────────────┐
  │ PHASE C: COMMIT (per sprint, scoped)        │
  │                                             │
  │ 5. For each validated sprint → COMMIT:        │
  │      git add <SPRINT.OWNED_FILES>            │
  │      git commit -m "feat(scope): sprint N ..."│
  │    (NO `git add --all` → leaks other sprints)│
  │ 6. Aggregate result; if ANY NEEDS_WORK →     │
  │    correction loop (max 3).                  │
  │    After 3 failures → STOP, ask user.        │
  │ 7. Update GOAL_DECOMPOSITION.md.             │
  └─────────────────────────────────────────────┘
```

### Commit Strategy: Per-Sprint (SCOPED)

**OLD rule (dangerous):** `git add --all` per group → sweeps every parallel sprint's changes into a single commit, hides attribution, and forces the dreaded "did I change what I was supposed to?" check to operate on the union of all changes.

**NEW rule (2026-08-13):** commit per validated sprint, scoped to OWNED_FILES:

```bash
# For sprint S3 (after PASS):
git add <S3.OWNED_FILES>            # pathspec, not --all
git commit -m "feat(scope): sprint S3 — [name] [PASS: X%]"
```

**Why per-sprint, not per-group:**
- Each commit is atomic and attributable (Easy to review/rollback per sprint).
- Verification "what did S3 change?" is unambiguous: `git diff $BASE_COMMIT -- <S3.OWNED_FILES>`.
- Parallel agents do NOT see each other's changes as their own — pathspec scoping contains noise.
- Pre-commit hooks see the right unit of work (vs. a mixed commit).

**Why NEVER `git add --all` in a parallel group:** the working tree mixes all sprints' changes. A bare `--all` would commit S3 + S4 + S5 together, and the next generator would lose the baseline that makes its OWNED_FILES verification clean.

## Rollback Strategy

When a group fails (per-sprint commit model):

```
Group 1: [S2, S3]
  S2 → PASS → committed (atomic)
  S3 → NEEDS_WORK (after 3 attempts)

  1. S2 is already committed (no need to roll back via uncommitted changes)
  2. Inspect S3's uncommitted working tree: `git status --short -- <S3.OWNED_FILES>`
  3. Ask user: "S3 failed. Options:
     a) Revert S2 commit, retry S3 alone
     b) Keep S2 commit, retry S3 (no other sprints affected — disjoint OWNED_FILES)
     c) Manual intervention"
```

Because each sprint's commit is scoped to OWNED_FILES, a failed S3 does not pollute S2's history. The HARD GATE on OWNED_FILES overlap means a failed sprint's companion usually commits cleanly.

## Planner Decision Matrix

| Scenario | Planner Action |
|----------|---------------|
| All sprints independent | Group all in Group 0, parallel all |
| Linear chain (S1→S2→S3) | Each in own group, sequential |
| Mixed (some deps, some not) | Build graph, assign groups |
| File conflict detected | Warn user, recommend split |
| 5+ parallel splits | Consider splitting into separate goals |
| Context >70% during parallel | Activate context-checkpoint, resume after |

## Example: Real Pipeline

### Scenario: Add Langfuse Tracing + Refactor + Tests

```
S1: Trace ID Propagation
    Files: core/agent/graph/state.py, core/agent/agent.py

S2: Manual Spans in Nodes
    Files: core/agent/graph/nodes.py
    Depends: S1 (needs trace_id in state)

S3: Refactor prompts.py
    Files: core/agent/graph/prompts.py
    Depends: NONE

S4: Scores Integration
    Files: core/agent/tracing.py, core/eval/run_eval.py
    Depends: S1 (needs langfuse client)

S5: Integration Tests
    Files: tests/test_tracing.py
    Depends: S1, S2, S4 (needs all features done)
```

### Dependency Graph

```
S1 ──→ S2 ──┐
 │           │
 └──→ S4 ──→ S5
       ↑
S3 ────┘ (S3 is independent)
```

### Parallel Groups

```
Group 0: [S1, S3]     ← S1 and S3 are independent
Group 1: [S2, S4]     ← both depend only on S1 (done in Group 0)
Group 2: [S5]          ← depends on S1, S2, S4 (all done)
```

### Time Savings

```
Sequential: S1→S2→S3→S4→S5 = 5 × avg(10min) = 50 min
Parallel:   G0(10) + G1(10) + G2(10) = 30 min
Saved: ~20 min (40%)
```
