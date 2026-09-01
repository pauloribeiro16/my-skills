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
- Any implementation that needs validation
- When unsure about scope or acceptance criteria

## What It Covers

1. **Contract Creation** — Write testable criteria with validation commands
2. **Subagent Dispatch** — Executor implements, code-reviewer verifies (Planner never does either)
3. **Validation Tiers** — T1-T4 system for ensuring criteria are actually testable
4. **Process Enforcement** — Rules that prevent self-implementation and self-verification
5. **Phased Goals** — Decompose large goals into sequential sprints
6. **Quality Tracking** — Quality Log, Calibration Log, Harness Audit

## Trials

Non-deterministic agents (LLM-based) produce different outputs on each run. To account for variance, contracts support **pass@k** evaluation: run the same task *k* times and measure how many trials pass.

- **Default:** `trials: 3` in the contract header
- The eval harness (configurable per project) exposes a `--trials` flag
- A criterion passes if it succeeds in ≥1 of k trials (pass@k)
- For deterministic changes (refactors, config), `trials: 1` is sufficient

Example contract header:

```yaml
trials: 3
pass_threshold: 2/3
```

Full reference: `references/trials-and-passk.md`

## Contract Workflow

```
CONTRACT → APPROVE → EXECUTE (Executor) → VALIDATE (code-reviewer) → COMMIT
```

### Step 0 — Pre-Flight (Planner, BEFORE writing contract)

**MANDATORY:** Read `execution/LESSONS.md` before starting any sprint. This file contains:
- Model reliability guide (which model for which task)
- Token waste anti-patterns (subagent explosion, context loops)
- Bottleneck files (frequently-read files to avoid)
- Edit tool discipline (re-read before edit)
- Recurring debugging themes (RAG, Langfuse, Neo4j)

Then activate the `project-conventions` skill (AEGIS-KG specific rules) before writing the contract. The contract MUST include the "Convention Compliance" section from the updated template.

### Step 1 — Contract Creation (Planner)

1. Planner writes CONTRACT.md (from template, including Convention Compliance section)
2. User approves (max 3 negotiation rounds)
3. **LAUNCH Executor subagent** — `task(subagent_type="general")`
4. **LAUNCH code-reviewer subagent** — `task(subagent_type="general")`
5. If FAIL → Executor fixes → code-reviewer re-checks (max 3 cycles)
6. **COMMIT validated sprint** — Planner does this, not Executor
7. After all PASS → update Quality Log

### Step 1.5 — Executor Pre-Implementation (MANDATORY)

**Before Executor writes any code, it MUST:**
1. Read `execution/LESSONS.md` (especially §3 Bottleneck Files and §4 Edit Tool Discipline)
2. Activate the `project-conventions` skill
3. Re-read all target files within the last 3 tool calls (per LESSONS §4)
4. Run the convention validation commands to establish baseline

If the Executor skips this, the code-reviewer MUST reject the work.

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

Full reference: `references/validation-tiers.md`

## Process Rules (Enforcement)

| Rule | What |
|------|------|
| Never Self-Implement | Always dispatch Executor |
| Never Self-Verify | Always dispatch code-reviewer |
| Commit After Sprint | `git add + commit` before next sprint |
| Tier Enforcement | MUST requires T3+ validation |
| **Read LESSONS.md First** | Both Planner and Executor MUST read `execution/LESSONS.md` before starting |
| **Activate project-conventions** | Both Executor and code-reviewer MUST activate the project conventions skill |
| **Convention Compliance** | Every contract MUST include the Convention Compliance section |
| **Re-Read Before Edit** | Executor MUST re-read target files within last 3 tool calls before editing |
| Validation Required | No criterion without command |

## Quality Tracking

- **Quality Log** — Record score after each validated sprint
- **Calibration Log** — Track divergences between reviewer and user judgment
- **Harness Audit** — Every 5 sprints, review what never catches issues

Full reference: `references/quality-tracking.md`

## Escape Hatches

STOP and ask user when:

| Situation | Action |
|-----------|--------|
| 3 failures on any criterion | STOP, report to user |
| Context >70% | Activate `context-checkpoint` skill |
| Executor finds unexpected blocker | STOP, ask user for guidance |
| User rejects contract | Revise and re-present (max 3 rounds) |

## Resources

### Templates
- `templates/CONTRACT.md` — Contract template with validation tiers
- `templates/GOAL_DECOMPOSITION.md` — Phased goal decomposition template
- `templates/QUALITY_LOG.md` — Quality log format
- `templates/CALIBRATION_LOG.md` — Calibration log for evaluator tuning
- `templates/SESSION_STATE.md` — Session state format

### References
- `references/contract-workflow.md` — Detailed workflow, correction loop, negotiation rounds
- `references/phased-decomposition.md` — When to decompose, phased goal workflow
- `references/validation-tiers.md` — Tier system examples and checklist
- `references/quality-tracking.md` — Quality Log, Calibration Log, Saturation Detection, Harness Audit
- `references/git-integration.md` — Commit strategy, message format, branch management, security hooks
- `references/execution-phases.md` — All 6 phases, pre-flight checks, explore subagent template
- `references/executor-prompt-template.md` — Full Executor prompt with tier enforcement
- `references/validator-prompt-template.md` — Full Validator prompt with tier checks
- `references/pipeline-template.md` — Multi-sprint pipeline, escape hatches
- `references/trials-and-passk.md` — Trials, pass@k evaluation, and scoring

## Use When

You need a systematic implementation approach with verifiable criteria and independent verification.
