---
name: sprint-contract
description: "Use before any implementation with 3+ file changes or complex tasks. Creates structured contracts with done criteria, validation commands, and quality dimensions. Supports phased goal decomposition. Trigger: implement feature, run sprint, execute contract, develop feature, create a contract"
---

# Sprint Contract Skill

Creates structured implementation contracts before coding. Based on Anthropic's generator-evaluator pattern with validation tiers and process enforcement.

## When to Activate

- Tasks with 3+ file changes
- Complex features requiring multiple steps
- Large goals that may need phased decomposition
- When you need verifiable implementation criteria

## What It Covers

1. **Contract Creation** — Write testable criteria with validation commands
2. **Subagent Dispatch** — Executor implements, code-reviewer verifies (Planner never does either)
3. **Validation Tiers** — T1-T4 system for ensuring criteria are actually testable
4. **Process Enforcement** — Rules that prevent self-implementation and self-verification
5. **Phased Goals** — Decompose large goals into sequential sprints
6. **Quality Tracking** — Quality Log, Calibration Log, Harness Audit

## Contract Workflow

```
CONTRACT → APPROVE → EXECUTE (Executor) → VALIDATE (code-reviewer) → COMMIT
```

1. Planner writes CONTRACT.md (from template)
2. User approves (max 3 negotiation rounds)
3. **LAUNCH Executor subagent** — `task(subagent_type="general")`
4. **LAUNCH code-reviewer subagent** — `task(subagent_type="general")`
5. If FAIL → Executor fixes → code-reviewer re-checks (max 3 cycles)
6. **COMMIT validated sprint** — Planner does this, not Executor
7. After all PASS → update Quality Log

**Rule: Planner NEVER implements. Planner NEVER verifies. Planner only delegates.**

## Validation Tiers

Every MUST criterion needs a **Tier 3** (behavioral) validation — not just syntax.

| Tier | Tests | Required for |
|------|-------|--------------|
| T1 Syntax | `python -m py_compile` | NICE only |
| T2 Import | `python -c "from module import X"` | SHOULD minimum |
| T3 Behavioral | `python -c "assert function_behavior"` | MUST minimum |
| T4 Integration | `python -c "graph.invoke(state)"` | Complex features |

**MUST criterion with only T1/T2 validation → FAIL the criterion**

## Process Rules (Enforcement)

| Rule | What |
|------|------|
| Never Self-Implement | Always dispatch Executor |
| Never Self-Verify | Always dispatch code-reviewer |
| Commit After Sprint | `git add + commit` before next sprint |
| Tier Enforcement | MUST requires T3+ validation |
| Validation Required | No criterion without command |

## Quality Tracking

- **Quality Log** — Record score after each validated sprint
- **Calibration Log** — Track divergences between reviewer and user judgment
- **Harness Audit** — Every 5 sprints, review what never catches issues

## Resources

- `templates/CONTRACT.md` — Contract template with validation tiers
- `references/contract-workflow.md` — Detailed workflow diagrams
- `references/phased-decomposition.md` — Multi-phase goal breakdown
- `references/validation-tiers.md` — Tier system examples and checklist

## Use When

You need a systematic implementation approach with verifiable criteria and independent verification — not just "implement this and hope it works."