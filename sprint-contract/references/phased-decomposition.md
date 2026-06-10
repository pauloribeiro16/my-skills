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
   └─ If NONE match → create single CONTRACT.md (skip to normal workflow)

2. If ANY match → ask user via question tool:
   "This goal seems large. Do you want to decompose into
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

## Contracts in Phased Mode

Each phase gets its own contract. Contracts are "guard rails" — they define the WHAT (acceptance criteria), not the HOW (implementation). The Executor subagent has freedom to choose how to implement within the criteria.

## Integration with Existing Workflows

- **Saturation Detection:** Applies per phase. If 3+ consecutive phases score 100%, increase complexity.
- **Harness Audit:** Runs after completing the full goal (counts as 1 sprint).
- **Calibration Log:** Records divergences per phase.
- **Quality Log:** Entry per phase + overall goal summary.
