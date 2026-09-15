# Git Integration Reference

Planner makes commits (not Generator). One commit per validated sprint. Only commits when Evaluator gives **PASS**.

## Commit Strategy

- **Planner makes commits** — not Generator
- **One commit per validated sprint** — never one commit per parallel group
- Only commits when Evaluator gives **PASS**
- **Scoped staging:** `git add <OWNED_FILES>` — NEVER `git add --all` / `git add .` when other sprints run in parallel (their changes would leak into your commit)
- If **NEEDS_WORK** → STOP, no commit

## Commit Message Format

```
feat(scope): description — phase N/M [PASS: X%]

- Contract: CONTRACT-phase-N.json
- Files: list of changed files
- Score: X% (MUST: Y/Z, SHOULD: Y/Z)
- Evaluator: [agent]
```

### Examples

Single contract:
```
feat(core): add trace_id propagation — [PASS: 100%]

- Contract: CONTRACT_S1.md
- Files: core/agent/graph/state.py, core/agent/agent.py
- Score: 100% (MUST: 4/4, SHOULD: 2/2)
- Evaluator: Evaluator
```

Phased goal:
```
feat(phase1): SubPhase A workflow — phase 1/3 [PASS: 94%]

- Contract: CONTRACT_phase1_subphase_a_poc.md
- Files: core/workflow/phase1/*.py (15 files)
- Score: 94% (MUST: 12/12, SHOULD: 4/4, NICE: 1/2)
- Evaluator: Evaluator
```

## Branch Management

### Single Contract
- Commit to current branch (master/main)

### Sequence of Contracts (phased goal)
- **ONE branch for the entire sequence**: `feature/<goal-name>` (e.g. `feature/aegis-p2-case01-tech-agnostic`)
- All contracts in the sequence commit to this SAME branch
- Each contract = one or more commits (per validated sprint)
- One PR at the end of the sequence → merge to main → delete branch
- **NEVER create `-v2`, `-rich`, `-part2` for the same sequence** — if a branch for the goal already exists (local or remote) and is not merged, REUSE it

### Branch Naming

```
feature/<goal-name>
Examples:
- feature/langfuse-tracing
- feature/aegis-p2-case01-tech-agnostic
- feature/eval-reform
```

## Anti-Duplicate Commit Rule

Before `git commit`, ALWAYS verify you are not re-committing existing work:

```bash
git log --oneline -3
git status --short
git diff --cached --stat
```

**If the change is already committed (same message/scope) or staged from a previous iteration → do NOT create a duplicate commit.** Common failure mode: two Generator iterations both commit the same change (`0059c9e` + `2bffd0f` in the Case_01 refactor), polluting history. Fix: skip, or amend the previous commit if it is un-pushed and the change is genuinely an iteration of the same unit of work.

## Security Hooks

- Pre-commit hooks run before each commit
- If secrets detected → commit blocked
- Generator must clean secrets before retry

**Common secrets to avoid:**
```bash
# Check before committing
grep -r "password\|secret\|api_key\|apikey" --include="*.py" .
```

## Integration with Workflow

### Single Contract
After step 10 (commit) → contract is complete

### Sequence of Contracts
- Confirm the **sequence branch** already exists; if not, create `feature/<goal-name>` ONCE
- After each contract PASS → commit to the sequence branch
- After ALL contracts PASS → follow merge flow:
  1. Ask user "Merge?"
  2. User approves → merge to main
  3. Delete sequence branch
  4. If merge error → keep branch for debug

---

## Before Creating Contract (Checklist)

Run before writing a new contract:

1. Read relevant AGENTS.md files (root + sub-AGENTS.md)
2. **`git fetch origin`** — confirm the base is a recent `origin/main`, not a stale local `main`
3. **Check for an existing sequence branch** — if a branch for this goal exists and is not merged, reuse it (do NOT create `-v2`)
4. Read `execution/CALIBRATION_LOG.md` for historical divergences
5. Review `execution/QUALITY_LOG.md` — if 3+ consecutive 100%, raise the bar
6. Check Criterion Effectiveness table for CANDIDATE FOR REMOVAL items
7. Understand existing code patterns
8. Identify all files that need changes
9. **For each criterion: write a Tier 3 validation command before finalizing**
10. If Calibration Log has OPEN items → address them in new criteria

## After Contract Approved

| Step | Action | Who |
|------|--------|-----|
| 1 | Launch Generator subagent to implement criteria | `task(subagent_type="general")` |
| 2 | Generator runs trials if `trials > 1` | Generator |
| 3 | Record pass@k results | Generator |
| 4 | Launch Evaluator subagent to verify | `task(subagent_type="general")` |
| 5 | If NEEDS_WORK → Generator fixes → Evaluator re-checks | max 3 cycles |
| 6 | If user disagrees → record in CALIBRATION_LOG.md | Evaluator |
| 7 | Update Criterion Effectiveness table | Evaluator |
| 8 | **COMMIT validated sprint immediately** (scoped: `git add <OWNED_FILES>` + commit) | Planner |
| 9 | If 5th sprint → run Harness Audit | Planner |

**Rule: Commit AFTER validation PASS, BEFORE next sprint.** In parallel groups, never `git add --all` — scope to the sprint's OWNED_FILES so each commit is atomic and attributable.
