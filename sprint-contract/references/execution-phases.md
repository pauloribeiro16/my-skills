# Execution Phases Reference

Detailed description of all 6 phases in the sprint orchestrator workflow.

## Phase 0 — Pre-flight Checks

Run these BEFORE any work:

| Check | Command | Purpose |
|-------|---------|---------|
| Python + venv | `python --version` | Verify runtime |
| PYTHONPATH | `echo $PYTHONPATH` | Import resolution |
| .env | `test -f .env && echo OK` | Config present |
| **Git fetch (NEW)** | `git fetch origin` | Avoid stale-base work (compare against `origin/main`, not local `main`) |
| **Branch base check (NEW)** | `git log --oneline origin/main..HEAD` | If empty, the branch base is current; if non-empty, the branch is ahead of `origin/main` (good). Critically: if `origin/main` is far ahead of the branch base, the branch is stale |
| Git status | `git status --short` | Know uncommitted changes |
| **Sequence branch (NEW)** | `git branch --show-current` | Confirm current branch is the sequence branch (e.g. `feature/aegis-p2-case01-tech-agnostic`), not a sibling `-v2`/`-rich` |
| AGENTS.md | `test -f AGENTS.md` | Project rules available |

If any check fails → fix before proceeding.

**Stale-base trap (learned 2026-08-12):** the Case_01 tech-agnostic refactor branch was built on `main@51a0916` (Aug 8) while `origin/main` had advanced 36 commits (Aug 12). The whole branch was obsolete. Always `git fetch origin` and reconcile against `origin/main` BEFORE dispatching.

---

## Phase 0.5 — Write Spec (Spec-Driven Development)

**When to use:** Features with 3+ files, architectural decisions, or multi-sprint pipelines.
**When to skip:** Simple bugfixes, single-file changes, trivial refactors.

```
Is this a complex feature (3+ files / arch decisions / multi-sprint)?
  YES → Write SPEC.md first (spec-driven development)
  NO  → Skip to Phase 1 (Explore)
```

### Spec Writing Workflow

```
1. Read project context (AGENTS.md, existing code patterns)
2. Write SPEC.md from template:
   a) Context: problem, current state, target state
   b) Requirements: MUST/SHOULD/NICE
   c) Architecture decisions: options + rationale
   d) Data model: entities + relationships
   e) API design: interfaces
   f) Acceptance criteria: testable criteria
   g) Implementation plan: phases + file changes
3. Present spec to user
4. Max 2 revision rounds
5. User approves spec
6. Save as SPEC.md in execution/ directory
```

### Spec Approval

```
Planner writes SPEC.md
         │
         ▼
   User reviews
         │
    ┌────┴────┐
    │         │
  APPROVE   REVISE
    │         │
    │         ▼
    │    Max 2 rounds
    │         │
    │    ┌────┴────┐
    │    │         │
    │  APPROVE   ABANDON
    │    │
    ▼    ▼
  Save SPEC.md
  → Continue to Phase 1
```

### Spec Quality Gate

Before proceeding, verify spec has:
- [ ] Every MUST requirement has acceptance criterion
- [ ] Architecture decisions include rationale
- [ ] File changes map to phases
- [ ] Edge cases documented
- [ ] Error scenarios documented

**If spec is incomplete → revise before continuing.**

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

Use the `sprint-contract` skill to write `CONTRACT.json`. Key rules:

- Every criterion must be **testable** (binary PASS/NEEDS_WORK)
- Include **test commands** for each criterion (T3+ for MUST)
- List **exact files** to create/modify
- Define **quality dimensions** with thresholds
- State **risks** and rollback plan

### If Using Spec-Driven Development

When a SPEC.md exists:
1. Read SPEC.md acceptance criteria
2. Map each acceptance criterion → contract criterion
3. Add "Spec Traceability" section to contract
4. Reference spec in contract header (`Spec File: SPEC.md`)
5. Ensure all MUST requirements from spec appear as MUST criteria in contract

### Contract Template

Copy from: `sprint-contract/templates/CONTRACT.json`

---

## Phase 3 — Approve

Present the contract to user. Get explicit approval before implementing.

Max 3 negotiation rounds. After that, present final version for approval or abandonment.

---

## Phase 4 — Execute

After approval, build dependency graph and dispatch by parallel group:

```
1. Build dependency graph from GOAL_DECOMPOSITION.md
2. Assign parallel groups (see references/parallel-execution.md)
3. **HARD GATE — file conflict check (NEW 2026-08-13):**
   For each pair (S, T) in same group:
     If S.OWNED_FILES ∩ T.OWNED_FILES ≠ ∅:
       → BLOCK the group → force sequential for the conflicting pair
4. **Record baseline (NEW):** `BASE_COMMIT=$(git rev-parse HEAD)`
5. For each group G (sequential between groups):

   ┌─────────────────────────────────────────────┐
   │ STEP A: EXECUTE — Write code                │
   │                                             │
   │ a. If G has 1 sprint → launch single Generator
   │ b. If G has 2+ sprints → launch ALL Generators in parallel:
   │    task(subagent_type="general", description="Sprint S2 — ...")
   │    task(subagent_type="general", description="Sprint S3 — ...")
   │    Each prompt includes OWNED_FILES + BASE_COMMIT (scoped git discipline).
   │                                             │
   │ c. WAIT for ALL Generators in G to complete  │
   │    ← DO NOT launch any Evaluator yet! →      │
   └─────────────────────────────────────────────┘
                      │
                      ▼
   ┌─────────────────────────────────────────────┐
   │ STEP B: VALIDATE — Read code                │
   │                                             │
   │ d. Launch Evaluator for EACH sprint in G│
   │    (evaluators can run in parallel)          │
   │    Each prompt includes OWNED_FILES + BASE_COMMIT.│
   │                                             │
   │ e. WAIT for ALL Evaluators to complete       │
   └─────────────────────────────────────────────┘
                      │
                      ▼
   ┌─────────────────────────────────────────────┐
   │ STEP C: COMMIT — per-sprint, scoped (NEW)   │
   │                                             │
   │ f. For each validated sprint P (sequential): │
   │      git add <P.OWNED_FILES>                │
   │      git commit -m "feat(scope): P ... [PASS: X%]"│
   │    (NEVER `git add --all` — would leak OTHER │
   │     sprints' changes into this commit.)     │
   │                                             │
   │ g. ANY NEEDS_WORK → correction loop (max 3 cycles).│
   │    After 3 failures → STOP, ask user.       │
   │                                             │
   │ h. After commits → update GOAL_DECOMPOSITION.md
   └─────────────────────────────────────────────┘
```

### ⚠️ CRITICAL: Generator → Evaluator is ALWAYS Sequential

**NEVER launch Generator and Evaluator at the same time for the same sprint.**

```
WRONG (NEVER DO THIS):
  task(Generator, S1)
  task(Evaluator, S1)    ← WRONG! S1 code not ready yet

CORRECT:
  task(Generator, S1)
  ── WAIT for S1 Generator to finish ──
  task(Evaluator, S1)    ← NOW code exists to review
```

**Why:** Evaluators READ code. If code doesn't exist yet (Generator still writing), Evaluator has nothing to validate. Launching Evaluator before Generator finishes = guaranteed NEEDS_WORK or garbage validation.

---

## Phase 5 — Evaluate

**⚠️ This phase ONLY runs AFTER Phase 4 (Execute) is COMPLETE for the entire group.**

After ALL Generators finish, launch Evaluators for each sprint:

```
PREREQUISITE: ALL Generators in group must have completed.

For each group G:
  For each sprint S in G:
    Launch Evaluator:
      Read CONTRACT-phase-N.json and verify ALL criteria.
      
      For each criterion:
      1. Run the test command from the contract
      2. Inspect the file(s)
      3. Record PASS or NEEDS_WORK with evidence
      
      Return a PASS/NEEDS_WORK table with file, line, and exact evidence.
      Be skeptical. If unsure → NEEDS_WORK.

  Evaluators can run in parallel (they only read + validate)
```

### Parallel Evaluation

When multiple sprints in same group:
- Launch ALL evaluators simultaneously
- Each evaluator validates independently
- Aggregate results after all complete
- If ANY evaluator returns NEEDS_WORK → correction loop for that sprint

### Correction Loop After Evaluation

If Evaluator returns NEEDS_WORK:
1. Planner reads Evaluator report
2. Planner dispatches Generator to fix (with specific error details)
3. Generator fixes → WAIT for Generator to finish
4. Planner dispatches Evaluator again to re-validate
5. Max 3 cycles per criterion. After 3 → STOP, ask user.

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
[ ] Evaluator returned PASS on ALL criteria
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
         ├─→ Generator(s)    (implement contracts — parallel in groups)
         └─→ Evaluator(s) (verify implementations — parallel in groups)

Communication via files:
  CONTRACT.json            ← sprint scope and criteria
  GOAL_DECOMPOSITION.md ← dependency graph + parallel groups
  QUALITY_LOG.md         ← validation results
  SESSION_STATE.md       ← session continuity

Parallel Dispatch:
  Group 0: [S1, S3]     → 2 Generators in parallel → 2 evaluators in parallel
  Group 1: [S2, S4]     → 2 Generators in parallel → 2 evaluators in parallel
  Between groups: sequential (G0 must PASS before G1 starts)
```

**Key principle**: Separate research/planning from implementation. Never implement what you haven't verified you understand. Sprints in same group execute in parallel when independent.

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
| I implemented something | Stop → dispatch Generator with same spec |
| I verified my own work | Stop → dispatch Evaluator with same spec |
| I forgot to commit | Stop → `git add <OWNED_FILES> + commit` → resume |
| I skipped validation tier check | Stop → re-run Evaluator with tier enforcement |
| I ran bare `git status`/`git diff` in a parallel group (NEW) | Stop → re-scope to OWNED_FILES; bare diff misattributes other sprints' changes |
| I used `git add --all` in a parallel group (NEW) | Stop → undo with `git reset HEAD -- <OWNED_FILES>` → re-stage with pathspec |
| I created a sibling branch (`-v2`, `-rich`) for an existing sequence (NEW) | Stop → delete, reuse the existing sequence branch |
| My branch base is stale vs `origin/main` (NEW) | Stop → fetch, rebase, re-audit before dispatching |

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
| Implement approved contract (1 sprint) | **Generator** | Contract-driven, sequential |
| Implement approved contract (N parallel) | **Generator(s)** | Parallel dispatch in groups |
| Verify implementation (1 sprint) | **Evaluator** | Independent, binary PASS/NEEDS_WORK |
| Verify implementation (N parallel) | **Evaluator(s)** | Parallel validation in groups |
| Write contract | **sprint-contract** skill | Structured negotiation |
| Context >70% | **context-checkpoint** skill | Prevent overflow |
