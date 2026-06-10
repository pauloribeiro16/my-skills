# Execution Phases Reference

Detailed description of all 6 phases in the sprint orchestrator workflow.

## Phase 0 — Pre-flight Checks

Run these BEFORE any work:

| Check | Command | Purpose |
|-------|---------|---------|
| Python + venv | `python --version` | Verify runtime |
| PYTHONPATH | `echo $PYTHONPATH` | Import resolution |
| .env | `test -f .env && echo OK` | Config present |
| Git status | `git status --short` | Know uncommitted changes |
| AGENTS.md | `test -f AGENTS.md` | Project rules available |

If any check fails → fix before proceeding.

---

## Phase 1 — Explore (if needed)

**Never implement what you don't understand.**

```
Is the code area unfamiliar?
  YES → Launch code-explorer subagent (max 15 steps)
  NO  → Read files directly, proceed to Phase 2
```

### Explore Subagent Prompt Template

```
Thoroughness: [quick|medium|very thorough]

I need to understand [SPECIFIC THING] in this codebase.

Find:
1. [specific file or pattern]
2. [how X connects to Y]
3. [where Z is configured]

Return:
- Complete list of files that reference [THING]
- How [THING] flows through the system
- Any existing abstraction layers
```

---

## Phase 2 — Write Contract

Use the `sprint-contract` skill to write `CONTRACT.md`. Key rules:

- Every criterion must be **testable** (binary pass/fail)
- Include **validation commands** for each criterion (T3+ for MUST)
- List **exact files** to create/modify
- Define **quality dimensions** with thresholds
- State **risks** and rollback plan

### Contract Template

Copy from: `sprint-contract/templates/CONTRACT.md`

---

## Phase 3 — Approve

Present the contract to user. Get explicit approval before implementing.

Max 3 negotiation rounds. After that, present final version for approval or abandonment.

---

## Phase 4 — Execute

After approval, launch Executor subagent:

```
Read CONTRACT.md and implement ALL criteria sequentially.

Rules:
- Implement one criterion at a time
- After each: run python -m py_compile on modified files
- Follow existing code patterns in neighboring files
- Never hardcode ports or secrets
- Report exactly what was created/modified

Start with criterion 1.
```

---

## Phase 5 — Validate

After Executor finishes, launch code-reviewer:

```
Read CONTRACT.md and verify ALL criteria.

For each criterion:
1. Run the validation command from the contract
2. Inspect the file(s)
3. Record PASS or FAIL with evidence

Classify any failures:
  IMPORT_ERROR, RUNTIME_ERROR, FILE_MISSING,
  SYNTAX_ERROR, LOGIC_ERROR

Return a PASS/FAIL table with file, line, and exact evidence.
Be skeptical. If unsure → FAIL.
```

### Error Classification

| Error Type | Description |
|------------|-------------|
| IMPORT_ERROR | Wrong import path |
| RUNTIME_ERROR | Code crashes |
| FILE_MISSING | File does not exist |
| SYNTAX_ERROR | Python syntax error |
| LOGIC_ERROR | Wrong behavior |
| PORT_ERROR | Hardcoded Neo4j port (7687/7474) |
| SECRET_ERROR | Hardcoded secret |

---

## Phase 6 — Deliver

Before delivering to user, verify Gate 3:

```
[ ] Validator returned PASS on ALL criteria
[ ] Quality dimensions met
[ ] Quality Log entry appended
[ ] SESSION_STATE.md updated
```

### Quality Log Template

Copy from: `sprint-contract/templates/QUALITY_LOG.md`

---

## Architecture Diagram

```
User → Planner (YOU)
         │
         ├─→ code-explorer  (understand codebase)
         ├─→ Executor       (implement contract)
         └─→ code-reviewer  (verify implementation)

Communication via files:
  CONTRACT.md      ← sprint scope and criteria
  QUALITY_LOG.md   ← validation results
  SESSION_STATE.md ← session continuity
```

**Key principle**: Separate research/planning from implementation. Never implement what you haven't verified you understand.

---

## Session Continuity

When resuming a session:
1. Read AGENTS.md (root)
2. Read SESSION_STATE.md if it exists
3. Go to exact continuation point
4. Resume work

### Session State Template

Copy from: `sprint-contract/templates/SESSION_STATE.md`

---

## Process Enforcement

If you catch yourself violating any rule:

| Violation | Correction |
|-----------|------------|
| I implemented something | Stop → dispatch Executor with same spec |
| I verified my own work | Stop → dispatch code-reviewer with same spec |
| I forgot to commit | Stop → `git add + commit` → resume |
| I skipped validation tier check | Stop → re-run Validator with tier enforcement |

**The harness exists to prevent self-evaluation bias. Trust the process.**

---

## Escape Hatches

STOP and ask user when:

| Situation | Action |
|-----------|--------|
| 3 correction loop failures | Report criterion, all attempts, ask for guidance |
| Pre-flight finds critical issue | Fix immediately if obvious, else ask |
| Context >70% | Activate context-checkpoint skill |
| Unsure about scope | Ask before assuming |
| Plan negotiation stuck | After 3 rounds, present final version |

---

## Subagent Dispatch Matrix

| Situation | Subagent | Why |
|-----------|----------|-----|
| Unfamiliar code area | **code-explorer** | Fast reconnaissance, no modification |
| Find specific pattern | **code-explorer** | Targeted grep + read |
| Map project structure | **code-explorer** | Quick directory scan |
| Design architecture | **code-architect** | Blueprint generation |
| Implement approved contract | **Executor** | Contract-driven, sequential |
| Verify implementation | **code-reviewer** | Independent, binary PASS/FAIL |
| Write contract | **sprint-contract** skill | Structured negotiation |
| Context >70% | **context-checkpoint** skill | Prevent overflow |
