# Phased Goal Decomposition Reference

Break large goals into smaller, iterative, and phased objectives.

## When to Decompose

| Criterion | Description | Example |
|-----------|-------------|---------|
| **C1** | Goal describes multiple distinct functionalities | "Create auth system + dashboard + API" |
| **C2** | Mentions 3+ different components/architectures | "Frontend + Backend + Database + Cache" |
| **C3** | Requires changes to 5+ files (estimated) | "Change schema, models, controllers, views, tests" |
| **C4** | Uses sequence connectors | "First X, then Y, finally Z" |
| **C5** | Involves non-trivial architectural decisions | "Choose between microservices or monolith" |

> **Max phases:** 5-7. More than that creates excessive overhead.

## Decomposition Workflow

```
1. Planner analyzes goal → checks criteria C1-C5
   └─ If NONE match → create single CONTRACT.json (skip to normal workflow)

2. If ANY match → ask user via question tool:
   "This goal seems large. Do you want to decompose into
    multiple phases with separate contracts?"

3. If NO → create single CONTRACT.json

4. If YES → Planner asks questions via question tool:
   a) Confirm the final objective
   b) Identify dependencies between parts
   c) Define implementation order
   d) Estimate files per phase

5. Planner generates GOAL_DECOMPOSITION.md

6. **Build dependency graph** — map which phases depend on which
7. **Assign parallel groups** — independent phases in same group
8. **Check for file conflicts** — same file in same group = force sequential
9. See `references/parallel-execution.md` for graph construction algorithm

10. User approves decomposition (1 round)

11. Planner creates N CONTRACT.json (one per phase)
    - Each contract: specific phase with limited scope
    - Contract N+1 references previous phase as dependency
    - Each contract includes its Parallel Group assignment

12. User approves ALL contracts at once

13. **Execute by parallel group:**
    For each group G (sequential between groups):
      a. For each phase in G → launch Generator subagent (parallel)
      b. For each phase in G → launch Evaluator subagent (parallel)
      c. If ALL PASS in G → commit group → update GOAL_DECOMPOSITION.md
      d. If ANY NEEDS_WORK in G → correction loop (max 3 cycles per phase)
      e. If still NEEDS_WORK after 3 → STOP, ask user

14. When all groups PASS:
    - Update QUALITY_LOG.md with full summary
    - Run Harness Audit if this is the 5th sprint
```

## Contracts in Phased Mode

Each phase gets its own contract. Contracts are "guard rails" — they define the WHAT (acceptance criteria), not the HOW (implementation). The Generator subagent has freedom to choose how to implement within the criteria.

## Integration with Existing Workflows

- **Saturation Detection:** Applies per phase. If 3+ consecutive phases score 100%, increase complexity.
- **Harness Audit:** Runs after completing the full goal (counts as 1 sprint).
- **Calibration Log:** Records divergences per phase.
- **Quality Log:** Entry per phase + overall goal summary.
- **Parallel Execution:** Phases without dependencies execute in parallel within groups. Commit per group, not per phase. See `references/parallel-execution.md`.

## Dependency Analysis Checklist

Before finalizing decomposition, verify:

- [ ] All file dependencies mapped (who writes, who reads)
- [ ] Parallel groups assigned correctly
- [ ] File conflicts checked (same file in same group = sequential)
- [ ] Each phase has clear input/output
- [ ] Max 7 phases (more = split into separate goals)
- [ ] Rollback plan covers parallel group failures
