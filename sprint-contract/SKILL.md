---
name: sprint-contract
description: "Use before any implementation with 3+ file changes or complex tasks. Creates structured JSON contracts with default-FAIL criteria, validation commands, and quality dimensions. Based on Anthropic's long-running agents (Planner/Generator/Evaluator). Supports spec-driven development, parallel sprint execution, and fresh-context evaluation. Trigger: implement feature, run sprint, execute contract, develop feature, create a contract, spec-first, write spec, parallel sprints"
---

# Sprint Contract Skill

Creates structured implementation contracts before coding. Based on **Anthropic's long-running agents** research: a three-role architecture (Planner, Generator, Evaluator) with **default-FAIL contracts**, **fresh-context evaluation**, and **agent-maintained handoff**.

## When to Activate

- Tasks with 3+ file changes
- Complex features requiring multiple steps
- Large goals that may need phased decomposition
- When you need verifiable implementation criteria
- Any implementation that needs validation
- When unsure about scope or acceptance criteria
- **When user says "spec-first" or "write spec first"** — activate spec-driven development
- **When pipeline has independent sprints** — enable parallel execution

## What It Covers

1. **Contract Creation** — JSON contract with default-FAIL criteria
2. **Three-Role Dispatch** — Planner writes spec, Generator implements, Evaluator verifies (fresh context)
3. **Validation Tiers** — T1-T4 system for ensuring criteria are actually testable
4. **Process Enforcement** — Rules that prevent self-implementation and self-verification
5. **Phased Goals** — Decompose large goals into sequential sprints
6. **Quality Tracking** — Quality Log, Calibration Log, Harness Audit
7. **Spec-Driven Development** — Write spec before contract for complex features
8. **Parallel Execution** — Independent sprints execute simultaneously in groups
9. **Default-FAIL Contract** — Every criterion starts `false`; cannot be marked passing without evidence
10. **Fresh-Context Evaluator** — Separate agent with no Write/Edit tools grades from a context that never saw the build

## Branching (1 branch per contract sequence)

**Rule: a SEQUENCE of contracts shares ONE branch.** Do NOT create a branch per contract.

| Scenario | Branch |
|----------|--------|
| Single contract | Current branch (no new branch) |
| **Sequence of contracts** (goal decomposed into multiple contracts) | **ONE branch for the whole sequence** — `feature/<goal-name>` |
| Hotfix / isolated experiment | Separate branch (merge to main when ready) |

**Examples:**
```
CORRECT:
  feature/aegis-p2-case01-tech-agnostic
    ├─ contract 1 → commit
    ├─ contract 2 → commit
    └─ contract 3 → commit

WRONG (anti-pattern):
  feature/aegis-p2-case01-tech-agnostic          # NO
  feature/aegis-p2-case01-tech-agnostic-v2       # NO
  feature/aegis-p2-case01-rich                   # NO
```

**Rules:**
- Never create `-v2`, `-rich`, `-part2`, `-2nd-pass` for the same sequence — continue on the existing branch.
- Each contract in the sequence = one or more commits on the sequence branch.
- One PR per sequence branch; merge once at the end.
- If a branch for the same goal already exists (local or remote) and is not merged → **reuse it**, do not create a sibling.

## Three Roles (Anthropic Architecture)

| Role | Job | Tools | Context |
|------|-----|-------|---------|
| **Planner** | Expands prompt → spec, scopes sprints, writes CONTRACT.json | Read, Write | Warms up once |
| **Generator** | Implements against contract, no access to Evaluator's session | Read, Write, Bash | Fresh per sprint |
| **Evaluator** | Reviews contract BEFORE code, grades result after (fresh context, no Write/Edit) | Read, Bash (read-only) | Fresh per eval |

**Rule: Generator NEVER grades its own work. Evaluator NEVER saw the build.**

## Trials

Non-deterministic agents (LLM-based) produce different outputs on each run. To account for variance, contracts support **pass@k** evaluation: run the same task *k* times and measure how many trials pass.

- **Default:** `trials: 3` in the contract header
- A criterion passes if it succeeds in ≥1 of k trials (pass@k)
- For deterministic changes (refactors, config), `trials: 1` is sufficient

Full reference: `references/trials-and-passk.md`

## Contract Workflow

```
SPEC (optional) → CONTRACT.json (default-FAIL) → NEGOTIATE (Evaluator reviews)
     → GENERATE (parallel groups) → EVALUATE (fresh context) → COMMIT
```

### CRITICAL: Generator and Evaluator are SEQUENTIAL, never parallel

```
CORRECT:
  Group 0: [S1, S3]
  ├─ Generator(S1)  ┐
  ├─ Generator(S3)  ├─ WAIT ALL finish
  └────────────────┘
  ├─ Evaluator(S1)  ┐
  ├─ Evaluator(S3)  ├─ WAIT ALL finish
  └────────────────┘
  → Commit

WRONG (NEVER DO THIS):
  ├─ Generator(S1)  ┐
  ├─ Evaluator(S1)   │  ← WRONG! Evaluator before Generator finishes
  ├─ Generator(S3)  ├─
  └────────────────┘
```

**Rule: Generators write code, Evaluators read code. Evaluators CANNOT evaluate code that doesn't exist yet.**

### Step 0 — Pre-Flight (Planner, BEFORE writing contract)

**MANDATORY:** Read `execution/LESSONS.md` before starting any sprint. This file contains:
- Model reliability guide (which model for which task)
- Token waste anti-patterns (subagent explosion, context loops)
- Bottleneck files (frequently-read files to avoid)
- Edit tool discipline (re-read before edit)
- Recurring debugging themes (RAG, Langfuse, Neo4j)

Then activate the `project-conventions` skill (AEGIS-KG specific rules) before writing the contract.

### Step 0.5 — Write Spec (Spec-Driven Development, OPTIONAL)

**When:** Features with 3+ files, architectural decisions, or multi-sprint pipelines.

1. Write SPEC.md from template (context, requirements, architecture, acceptance criteria)
2. Present spec to user (max 2 revision rounds)
3. User approves spec
4. Save as `execution/SPEC.md`

**When to skip:** Simple bugfixes, single-file changes, trivial refactors.

Full reference: `references/spec-driven-development.md`

### Step 1 — Contract Creation (Planner)

1. Planner writes **CONTRACT.json** (from template, default-FAIL: all criteria `passed: false`)
2. **If spec exists:** Map spec requirements → contract criteria (add `spec_file` field)
3. User approves (max 3 negotiation rounds)
4. **If this contract is part of a sequence:** confirm the sequence branch exists and reuse it (see Branching). Do NOT create a branch per contract.
5. **Record git baseline:** `BASE_COMMIT=$(git rev-parse HEAD)` and derive each sprint's `OWNED_FILES` from `files_to_change`.
6. **LAUNCH Generator subagent(s)** — `task(subagent_type="general")` (parallel if in same group)
7. **WAIT for ALL Generators to finish** — NEVER launch Evaluator before Generator completes
8. **LAUNCH Evaluator subagent(s)** — `task(subagent_type="general")` (fresh context, no Write/Edit)
7. If NEEDS_WORK → Generator fixes → Evaluator re-grades (max 3 cycles)
8. **COMMIT validated sprint** — Planner does this, not Generator, using `git add <OWNED_FILES> + git commit` (never `git add --all` in a parallel group)
9. After all PASS → update Quality Log

### Step 1.5 — Generator Pre-Implementation (MANDATORY)

**Before Generator writes any code, it MUST:**
1. Read `execution/LESSONS.md` (especially §3 Bottleneck Files and §4 Edit Tool Discipline)
2. Activate the `project-conventions` skill
3. Re-read all target files within the last 3 tool calls (per LESSONS §4)
4. Run the convention validation commands to establish baseline

If the Generator skips this, the Evaluator MUST reject the work.

**Rule: Planner NEVER implements. Planner NEVER verifies. Planner only delegates.**

## Validation Tiers

Every MUST criterion needs a **Tier 3** (behavioral) validation — not just syntax.

| Tier | Tests | Required for |
|------|-------|--------------|
| T1 Syntax | `python -m py_compile` | NICE only |
| T2 Import | `python -c "from module import X"` | SHOULD minimum |
| T3 Behavioral | `python -c "assert function_behavior"` | MUST minimum |
| T4 Integration | `python -c "graph.invoke(state)"` | Complex features |

**MUST criterion with only T1/T2 validation → NEEDS_WORK the criterion**

Full reference: `references/validation-tiers.md`

## Process Rules (Enforcement)

| Rule | What |
|------|------|
| Never Self-Implement | Always dispatch Generator |
| Never Self-Verify | Always dispatch Evaluator (fresh context) |
| Commit Per Sprint | `git add <OWNED_FILES> + commit` per validated sprint — NEVER `git add --all` in a parallel group |
| Tier Enforcement | MUST requires T3+ validation |
| **Read LESSONS.md First** | Both Planner and Generator MUST read `execution/LESSONS.md` before starting |
| **Activate project-conventions** | Both Generator and Evaluator MUST activate the project conventions skill |
| **Re-Read Before Edit** | Generator MUST re-read target files within last 3 tool calls before editing |
| Validation Required | No criterion without command |
| **Spec-First** | Complex features (3+ files) MUST write spec before contract |
| **Default-FAIL** | Every criterion starts `passed: false`; cannot flip to `true` without opening evidence |
| **Fresh-Context Evaluator** | Evaluator has NO Write/Edit tools, never saw the build |
| **Upfront Negotiation** | Evaluator reviews CONTRACT.json BEFORE Generator writes code |
| **Evidence Enforcement** | Criterion stays `false` unless evidence file is Read first |
| **NEVER Parallelize Generator + Evaluator** | Generators write code, Evaluators read code. MUST wait for ALL Generators to finish BEFORE launching ANY Evaluator |
| **Dependency Analysis** | Multi-sprint pipelines MUST build dependency graph before execution |
| **Parallel Groups** | Independent sprints execute simultaneously in groups |
| **Scoped Git Discipline** | In parallel groups, every `git status/diff/add` MUST be path-scoped to OWNED_FILES. Never bare `git diff`, `git status`, or `git add --all` |
| **File Conflict = HARD GATE** | Same file in same parallel group BLOCKS the group → force sequential. Not a WARN |
| **Commit Per Sprint** | Commit each validated sprint with `git add <OWNED_FILES>` — atomic and attributable; no group-level `git add --all` |
| **1 Branch Per Sequence** | A sequence of contracts shares one branch. Never branch per contract (see Branching section) |

## P0 Escalation Loop

**P0 (Reasoned Disagreement) is not a failure — it is a required protocol.** Subagents (Generator/Evaluator) MUST raise P0 when the task conflicts with established methodology, has unconsidered repercussions, or rests on wrong assumptions. The Orchestrator MUST NOT override a valid P0 by re-dispatching the same instructions.

**Loop:**
```
1. Subagent audits the target (read-only) BEFORE executing.
2. Subagent detects conflict with methodology/reality.
   → STOPS, reports P0 with evidence (file:line, commands run).
3. Orchestrator verifies the claim (does NOT blindly accept or reject).
4. Orchestrator revises scope (Option A/B/C) and re-dispatches with the revised prompt.
5. Subagent re-audits and only then executes. No re-litigation after user reaffirms.
```

**Real cases (Methodology repo, 2026-08):**
- **Phase 1 PG/SG→PO/SO:** plan assumed Doc 10 had live PG/SG IDs to migrate. Audit found 42 hits — all in Appendix A (DEPRECATED alias table). Migration would corrupt provenance. → P0 raised, scope revised to "skip migration", zero commits.
- **Phase 2 PF 1.0:** plan proposed renaming `NIST_Privacy_FW_1.1_subcategories.md` → 1.0. Audit found the canonical `NIST_PF_1.0_subcategories.md` already existed (100 subcats). Rename would create duplicate authoritative lists. → P0 raised, Orchestrator picked Option B (field names → 1.0 + body paths → canonical), no rename.

**Rules:**
- Generator/Evaluator MUST audit before executing (never skip to "just do it").
- Orchestrator MUST verify a P0 claim with its own read-only checks before revising.
- If user reaffirms the original intent after P0 → comply without re-litigation (P7).

## Quality Tracking

- **Quality Log** — Record score after each validated sprint
- **Calibration Log** — Track divergences between evaluator and user judgment
- **Harness Audit** — Every 5 sprints, review what never catches issues

Full reference: `references/quality-tracking.md`

## Escape Hatches

STOP and ask user when:

| Situation | Action |
|-----------|--------|
| 3 failures on any criterion | STOP, report to user |
| Context >70% | Activate `context-checkpoint` skill |
| Generator finds unexpected blocker | STOP, ask user for guidance |
| User rejects contract | Revise and re-present (max 3 rounds) |

## Resources

### Templates
- `templates/CONTRACT.json` — **Canonical JSON contract** with default-FAIL criteria
- `templates/SPEC.md` — Spec-driven development template (spec-first)
- `templates/GOAL_DECOMPOSITION.md` — Phased goal decomposition template
- `templates/QUALITY_LOG.md` — Quality log format
- `templates/CALIBRATION_LOG.md` — Calibration log for evaluator tuning
- `templates/SESSION_STATE.md` — Session state format

### References
- `references/contract-workflow.md` — Detailed workflow, negotiation rounds, correction loop
- `references/json-contract-format.md` — JSON structure, default-FAIL, evidence enforcement
- `references/fresh-context-evaluator.md` — Fresh-context evaluator pattern, calibration
- `references/phased-decomposition.md` — When to decompose, phased goal workflow
- `references/validation-tiers.md` — Tier system examples and checklist
- `references/quality-tracking.md` — Quality Log, Calibration Log, Saturation Detection, Harness Audit
- `references/git-integration.md` — Commit strategy, message format, branch management, security hooks
- `references/execution-phases.md` — All phases including Phase 0.5 (Spec), pre-flight checks, generator/evaluator templates
- `references/generator-prompt-template.md` — Full Generator prompt with tier enforcement
- `references/evaluator-prompt-template.md` — Full Evaluator prompt with tier checks
- `references/pipeline-template.md` — Multi-sprint pipeline with parallel groups, escape hatches
- `references/trials-and-passk.md` — Trials, pass@k evaluation, and scoring
- `references/parallel-execution.md` — Dependency graph, parallel groups, commit strategy, conflict detection
- `references/spec-driven-development.md` — Spec-first workflow, spec→contract mapping, quality checklist

## Use When

You need a systematic implementation approach with verifiable criteria and independent verification, aligned with Anthropic's long-running agents research.
