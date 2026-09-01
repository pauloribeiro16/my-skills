# Git Integration Reference

Planner makes commits (not Executor). One commit per validated sprint. Only commits when code-reviewer gives **PASS**.

## Commit Strategy

- **Planner makes commits** — not Executor
- **One commit per validated sprint**
- Only commits when code-reviewer gives **PASS**
- If **FAIL** → STOP, no commit

## Commit Message Format

```
feat(scope): description — phase N/M [PASS: X%]

- Contract: CONTRACT-phase-N.md
- Files: list of changed files
- Score: X% (MUST: Y/Z, SHOULD: Y/Z)
- Reviewer: [agent]
```

### Examples

Single contract:
```
feat(core): add trace_id propagation — [PASS: 100%]

- Contract: CONTRACT_S1.md
- Files: core/agent/graph/state.py, core/agent/agent.py
- Score: 100% (MUST: 4/4, SHOULD: 2/2)
- Reviewer: code-reviewer
```

Phased goal:
```
feat(phase1): SubPhase A workflow — phase 1/3 [PASS: 94%]

- Contract: CONTRACT_phase1_subphase_a_poc.md
- Files: core/workflow/phase1/*.py (15 files)
- Score: 94% (MUST: 12/12, SHOULD: 4/4, NICE: 1/2)
- Reviewer: code-reviewer
```

## Branch Management

### Single Contract
- Commit to current branch (master/main)

### Phased Goal
- Create branch `sprint/nome-do-objetivo` before starting
- All phases commit to this branch
- After all PASS: ask user "Merge?"
- User approves → merge to main → delete branch
- If merge error → keep branch for debug

### Branch Naming

```
sprint/<goal-name>
Examples:
- sprint/langfuse-tracing
- sprint/phase1-subphase-a
- sprint/eval-reform
```

## Security Hooks

- Pre-commit hooks run before each commit
- If secrets detected → commit blocked
- Executor must clean secrets before retry

**Common secrets to avoid:**
```bash
# Check before committing
grep -r "password\|secret\|api_key\|apikey" --include="*.py" .
```

## Integration with Workflow

### Single Contract
After step 10 (commit) → contract is complete

### Phased Goal
- After each phase PASS → commit to sprint branch
- After all phases PASS → follow merge flow:
  1. Ask user "Merge?"
  2. User approves → merge to main
  3. Delete sprint branch
  4. If merge error → keep branch for debug

---

## Before Creating Contract (Checklist)

Run before writing a new contract:

1. Read relevant AGENTS.md files (root + sub-AGENTS.md)
2. Read `execution/CALIBRATION_LOG.md` for historical divergences
3. Review `execution/QUALITY_LOG.md` — if 3+ consecutive 100%, raise the bar
4. Check Criterion Effectiveness table for CANDIDATE FOR REMOVAL items
5. Understand existing code patterns
6. Identify all files that need changes
7. **For each criterion: write a Tier 3 validation command before finalizing**
8. If Calibration Log has OPEN items → address them in new criteria

## After Contract Approved

| Step | Action | Who |
|------|--------|-----|
| 1 | Launch Executor subagent to implement criteria | `task(subagent_type="general")` |
| 2 | Executor runs trials if `trials > 1` | Executor |
| 3 | Record pass@k results | Executor |
| 4 | Launch code-reviewer subagent to verify | `task(subagent_type="general")` |
| 5 | If FAIL → Executor fixes → code-reviewer re-checks | max 3 cycles |
| 6 | If user disagrees → record in CALIBRATION_LOG.md | code-reviewer |
| 7 | Update Criterion Effectiveness table | code-reviewer |
| 8 | **COMMIT validated sprint immediately** | Planner |
| 9 | If 5th sprint → run Harness Audit | Planner |

**Rule: Commit AFTER validation PASS, BEFORE next sprint.**
