---
name: planner-harness
description: "Anthropic-style generator-evaluator harness for systematic implementation. Planner creates contract, launches Executor subagent to implement, launches Validator subagent to verify. Supports multi-sprint pipelines with sequential dependencies. Trigger: implement, build, create feature, sprint, execute contract, develop feature."
---

# Skill: Planner Harness

Systematic implementation workflow using the **Planner → Executor → Validator** pattern, inspired by Anthropic's generator-evaluator harness design.

## When to Activate

Activate this skill when:
- User says: "implement", "build", "create feature", "develop feature"
- User says: "run sprint", "execute contract"
- Task involves **3+ file changes**
- Task requires **validation** (not just quick edits)
- Task is **complex** (multiple steps, dependencies)

## Core Pattern

```
Planner (primary, glm-5.1)
  ├── 1. ANALYSE request
  ├── 2. DECOMPOSE into sprint(s) if needed
  ├── 3. WRITE contract(s) to execution/CONTRACT_S*.md
  ├── 4. PRESENT to user — WAIT for approval
  ├── 5. FOR each sprint (sequential):
  │     ├── a. LAUNCH Executor (MiniMax-M2.7) via task tool
  │     ├── b. LAUNCH Validator (MiniMax-M2.7) via task tool
  │     ├── c. IF FAIL → Executor fixes → re-launch Validator
  │     ├── d. IF 3 failures → STOP, report to user
  │     └── e. IF PASS → update Quality Log → next sprint
  └── 6. REPORT final results
```

## Sprint Types

| Type | Files | Complexity | Pipeline |
|------|-------|-----------|----------|
| Single sprint | 1-2 files | Low | No |
| Standard sprint | 3-5 files | Medium | No |
| **Multi-sprint** | 6+ files | High | **Yes** (S1→S2→S3) |

## Step-by-Step Workflow

### Step 1: Analyse

1. Read root `AGENTS.md` and relevant sub-AGENTS.md
2. Use **Explore** subagent if codebase is unfamiliar:
   ```
   task({
     subagent_type: "explore",
     prompt: "Explore [area] to understand structure..."
   })
   ```
3. Identify ALL files that need changes
4. Estimate complexity → decide: single sprint or multi-sprint?

### Step 2: Decompose (if multi-sprint)

Break work into sequential sprints with clear dependencies:

```
Sprint S1: Foundation — create data structures, add fields
  → No dependencies
Sprint S2: Implementation — add logic, modify nodes
  → Depends on S1
Sprint S3: Integration — wire everything together, cleanup
  → Depends on S2
```

Rules for decomposition:
- Each sprint must be independently verifiable
- Sprints should not modify the same lines (minimize merge conflicts)
- Earlier sprints provide infrastructure for later ones
- Max 5 sprints per pipeline

### Step 3: Write Contract(s)

Use the sprint-contract skill template. For multi-sprint:

```
execution/
├── CONTRACT_S1.md    ← Sprint 1 contract
├── CONTRACT_S2.md    ← Sprint 2 contract  
├── CONTRACT_S3.md    ← Sprint 3 contract
└── (existing files)
```

Each contract MUST have:
- **Scope**: What files change and why
- **Done When**: Testable, binary criteria (e.g., "File compiles", "Function X exists")
- **Validation Commands**: Exact commands with expected output
- **Quality Dimensions**: Correctness, Pattern Compliance, No Regressions, Data Integrity
- **Files to Change**: File path + action (create/modify)
- **Risks**: What could break, rollback plan

### Step 4: Present and Approve

Present contract(s) to user. Format:

```
## Contract Ready for Approval

**Sprint:** S1 — Trace ID Propagation
**Files:** 2 files (state.py, agent.py)
**Estimated time:** 5 min

### Summary
[One-line description]

### Criteria
- [ ] state.py compiles
- [ ] agent.py compiles  
- [ ] trace_id propagated correctly

### Validation
- `python -m py_compile core/agent/graph/state.py`
- `python -m py_compile core/agent/agent.py`

Approve? (yes / no / changes)
```

Max 3 negotiation rounds. After approval → Step 5.

### Step 5: Execute Sprint

#### 5a. Launch Executor

Use the **task** tool to launch the Executor subagent:

```javascript
task({
  subagent_type: "executor",
  description: "Sprint S1 implementation",
  prompt: `
You are the Executor subagent implementing CONTRACT_S1.

## Contract
Read the contract at: execution/CONTRACT_S1.md

## Instructions
1. Read the contract
2. Read relevant AGENTS.md files
3. Implement ALL criteria sequentially
4. Run compile checks after each file
5. Report EXACTLY what was changed

## Critical Rules
- Never use port 7474 or 7687 (only 7688/7475)
- Use os.getenv() for all secrets/configs
- Follow existing code patterns
- Do NOT evaluate your own work — that's for Validator

## Return Format
```
Implemented:
- Created: path/to/file.py (N lines)
- Modified: path/to/file.py (lines X-Y)
- Deleted: path/to/file.py

Compile checks:
- file1.py: OK / FAIL
- file2.py: OK / FAIL

Issues encountered:
- [none / list]
```
`
})
```

**CRITICAL**: The Executor receives the contract path and implements it. It does NOT read this skill.

#### 5b. Launch Validator

After Executor returns, launch Validator:

```javascript
task({
  subagent_type: "validator", 
  description: "Sprint S1 validation",
  prompt: `
You are the Validator subagent verifying CONTRACT_S1 implementation.

## Contract
Read the contract at: execution/CONTRACT_S1.md

## Instructions
1. Read the contract
2. Run ALL validation commands from the contract
3. Check each criterion — PASS or FAIL (binary)
4. Classify any errors
5. Report specific file:line for failures

## Critical Rules
- Only PASS or FAIL — never "looks good"
- Be SKEPTICAL — you did NOT build this
- Check ALL criteria, not just some
- If unsure → FAIL

## Return Format
```
## Validation Result

| Criterion | Status | Evidence |
|-----------|--------|----------|
| [criterion 1] | PASS/FAIL | [evidence] |
| [criterion 2] | PASS/FAIL | [evidence] |

**Verdict: PASS/FAIL** (X/Y criteria passed)

**Failed criteria:**
- [list with file:line and exact problem]

**Next step:**
- [if FAIL: what Executor must fix]
- [if PASS: ready for next sprint]
```
`
})
```

**CRITICAL**: The Validator is read-only. It does NOT modify files.

#### 5c. Correction Loop

| Attempt | Action |
|---------|--------|
| 1 | Executor implements → Validator checks |
| 2 | If FAIL → Executor fixes → Validator re-checks |
| 3 | If FAIL again → Executor fixes → Validator re-checks |
| 4+ | If still FAIL → **STOP**, report to user |

After each Validator run:
- **PASS**: Update Quality Log, proceed to next sprint (or finish)
- **FAIL**: Feed Validator's report to Executor, re-launch Executor

### Step 6: Update Quality Log

After all sprints PASS, append to `execution/QUALITY_LOG.md`:

```markdown
| Date | Contract | Correctness | Patterns | Regressions | Data | Verdict |
|------|----------|-------------|----------|-------------|------|---------|
| YYYY-MM-DD | Feature Name | 100% | 4/4 | 100% | 100% | PASS |
```

### Step 7: Report to User

Final report format:

```
## Implementation Complete ✅

### Sprints Executed
| Sprint | Files | Status |
|--------|-------|--------|
| S1 | 2 files | PASS |
| S2 | 3 files | PASS |

### Files Changed
- `core/agent/state.py` — added trace_id field
- `core/agent/agent.py` — propagate trace_id

### Quality
- Correctness: 100%
- Pattern Compliance: 4/4
- No Regressions: 100%
- Data Integrity: 100%

### Next Steps
- [any follow-up work]
```

## Multi-Sprint Pipeline Example

```
User: "Add Langfuse tracing with spans for cypher generation,
      cypher execution, and answer generation"

Planner analysis:
  → 3 files to change (state.py, agent.py, nodes.py)
  → But nodes.py changes depend on state.py + agent.py changes
  → DECOMPOSE into 2 sprints:

Sprint S1: Trace ID Propagation
  - state.py: add trace_id field
  - agent.py: create trace, pass to state
  - Validation: compile checks, grep ports

Sprint S2: Manual Spans in Nodes
  - nodes.py: add spans in generate_and_execute()
  - nodes.py: add spans in generate_answer()
  - Validation: compile checks, run agent, check Langfuse UI

Execution:
  1. Write CONTRACT_S1.md + CONTRACT_S2.md
  2. Present to user
  3. User approves
  4. Execute S1 → Executor → Validator → PASS
  5. Execute S2 → Executor → Validator → PASS
  6. Update Quality Log
  7. Report to user
```

## Critical Rules

1. **Planner never implements** — only orchestrates
2. **Always get user approval** before launching Executor
3. **Sequential execution** — S1 must PASS before S2 starts
4. **Max 3 correction cycles** per sprint
5. **Binary evaluation** — Validator only says PASS or FAIL
6. **Never skip validation** — even for "simple" changes
7. **Update Quality Log** after every validated sprint

## Escape Hatches

| Situation | Action |
|-----------|--------|
| 3 failures on any criterion | STOP, report to user |
| Context >70% | Activate `context-checkpoint` skill |
| Neo4j ports wrong (7474/7687) | Fix immediately (critical) |
| Executor finds unexpected blocker | STOP, ask user for guidance |
| User rejects contract | Revise and re-present (max 3 rounds) |

## Agent Configuration

This skill assumes the following agents are configured:

| Agent | Model | Mode | Role |
|-------|-------|------|------|
| **planner** | `zai-coding-plan/glm-5.1` | primary | Orchestrator (loads this skill) |
| **executor** | `minimax/MiniMax-M2.7` | subagent | Implementation |
| **validator** | `minimax/MiniMax-M2.7` | subagent | Verification |
| **explore** | `zai-coding-plan/glm-5.1` | subagent | Fast exploration |

## References

- `references/executor-prompt-template.md` — Full Executor prompt template
- `references/validator-prompt-template.md` — Full Validator prompt template  
- `references/contract-pipeline-template.md` — Multi-sprint pipeline template