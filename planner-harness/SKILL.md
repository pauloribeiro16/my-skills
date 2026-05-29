---
name: planner-harness
description: "Anthropic-style generator-evaluator harness for systematic implementation. Planner creates contract, launches Executor subagent to implement, launches Validator subagent to verify. Supports multi-sprint pipelines with sequential dependencies. Trigger: implement, build, create feature, sprint, execute contract, develop feature."
---

# Planner Harness Skill

Systematic implementation using **Planner → Executor → Validator** pattern.

## When to Activate

- User says: "implement", "build", "create feature"
- User says: "run sprint", "execute contract"
- Task involves **3+ file changes**
- Task requires **validation**

## Core Pattern

```
Planner
  ├── 1. ANALYSE request
  ├── 2. DECOMPOSE into sprint(s) if needed
  ├── 3. WRITE contract(s) to execution/CONTRACT_S*.md
  ├── 4. PRESENT to user — WAIT for approval
  └── 5. FOR each sprint:
        ├── LAUNCH Executor → task(subagent_type="general")
        ├── LAUNCH Validator → task(subagent_type="general")
        ├── IF FAIL → Executor fixes → re-launch Validator
        ├── IF 3 failures → STOP, report to user
        └── IF PASS → COMMIT → next sprint
```

## Sprint Types

| Type | Files | Pipeline |
|------|-------|----------|
| Single | 1-2 | No |
| Standard | 3-5 | No |
| Multi | 6+ | **Yes** (S1→S2→S3) |

## Step-by-Step

### 1. Analyse
1. Read `AGENTS.md` and relevant sub-AGENTS.md
2. Use **Explore** subagent if codebase is unfamiliar
3. Identify ALL files to change
4. Estimate complexity → single or multi-sprint?

### 2. Decompose (if multi-sprint)
```
Sprint S1: Foundation — no dependencies
Sprint S2: Implementation — depends on S1
Sprint S3: Integration — depends on S2
```
- Each sprint must be independently verifiable
- Max 5 sprints per pipeline

### 3. Write Contract(s)
Each contract MUST have:
- **Scope**: What files change and why
- **Done When**: Testable, binary criteria
- **Validation Commands**: Exact commands with expected output
- **Quality Dimensions**: Correctness, Pattern Compliance, No Regressions, Data Integrity
- **Files to Change**: File path + action
- **Risks**: What could break, rollback plan

### 4. Present and Approve
Max 3 negotiation rounds. After approval → Step 5.

### 5. Execute Sprint

#### 5a. Launch Executor
```
task({
  subagent_type: "executor",
  description: "Sprint S1 implementation",
  prompt: `
You are the Executor implementing CONTRACT_S1.

## Contract
Read: execution/CONTRACT_S1.md

## Instructions
1. Read contract
2. Read relevant AGENTS.md files
3. Implement ALL criteria sequentially
4. Run compile checks after each file
5. Report EXACTLY what was changed

## Critical Rules
- Never hardcode ports (7688/7475 only)
- Use os.getenv() for secrets
- Do NOT evaluate your own work
`
})
```

#### 5b. Launch Validator
```
task({
  subagent_type: "validator", 
  description: "Sprint S1 validation",
  prompt: `
You are the Validator verifying CONTRACT_S1.

## Contract
Read: execution/CONTRACT_S1.md

## Instructions
1. Run ALL validation commands
2. Check each criterion — PASS or FAIL only
3. Report file:line for failures

## Critical Rules
- Only PASS or FAIL — never "looks good"
- Be SKEPTICAL — you did NOT build this
- If unsure → FAIL
`
})
```

#### 5c. Correction Loop
| Attempt | Action |
|---------|--------|
| 1 | Executor implements → Validator checks |
| 2 | If FAIL → Executor fixes → Validator re-checks |
| 3 | If FAIL again → Executor fixes → Validator re-checks |
| 4+ | If still FAIL → **STOP**, report to user |

### 6. COMMIT After Validation
- **Planner makes commits** (not Executor)
- **One commit per validated sprint**
- **Only commits when Validator gives PASS**
- Message format: `feat(scope): description — phase N/M [PASS: X%]`

### 7. Update Quality Log
After all sprints PASS, append to `execution/QUALITY_LOG.md`.

## Critical Rules

| Rule | Why |
|------|-----|
| Planner never implements | Separation of concerns |
| Get user approval before executing | Prevents scope creep |
| Sequential execution | Earlier sprints provide infrastructure |
| Max 3 correction cycles | Prevents infinite loops |
| Binary evaluation | Clear, actionable feedback |
| Never skip validation | Quality gate |

## Escape Hatches

STOP and ask user when:

| Situation | Action |
|-----------|--------|
| 3 failures on any criterion | STOP, report to user |
| Context >70% | Activate `context-checkpoint` skill |
| Neo4j ports wrong (7474/7687) | Fix immediately (critical) |
| Executor finds unexpected blocker | STOP, ask user for guidance |
| User rejects contract | Revise and re-present (max 3 rounds) |

## Resources

### References
- `references/executor-prompt-template.md` — Full Executor prompt with tier validation enforcement
- `references/validator-prompt-template.md` — Full Validator prompt with tier checks
- `references/contract-pipeline-template.md` — Multi-sprint pipeline, escape hatches, user presentation format

### Templates
- `sprint-contract/templates/CONTRACT.md` — Contract template
- `sprint-contract/templates/GOAL_DECOMPOSITION.md` — Phased goal template
- `sprint-contract/templates/QUALITY_LOG.md` — Quality log format

## Agent Configuration

| Agent | Model | Role |
|-------|-------|------|
| **planner** | `zai-coding-plan/glm-5.1` | Orchestrator (loads this skill) |
| **executor** | `minimax/MiniMax-M2.7` | Implementation |
| **validator** | `minimax/MiniMax-M2.7` | Verification |
| **explore** | `zai-coding-plan/glm-5.1` | Fast exploration |