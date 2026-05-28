# CONTRACT — [Feature Name]

**Date:** YYYY-MM-DD
**Planner:** [name]
**Status:** DRAFT → NEGOTIATING → APPROVED → IMPLEMENTING → VALIDATED
**Phase:** # of N  ← [omit if single-contract goal]
**Depends On:** Phase X  ← [omit for phase 1 or single-contract]
**Parent Goal:** `GOAL_DECOMPOSITION.md`  ← [omit if single-contract goal]

---

## Trials

`trials: 3` (default)

Run each criterion the specified number of trials. Record pass@k results in Quality Log:
- pass@1, pass@2, pass@3 for each criterion
- Final verdict requires majority pass (≥2/3 trials)

---

## Scope

[What files change and why. Be specific about the goal.]

---

## Output Criteria (what was produced)

| # | Criterion | Weight | Result |
|---|-----------|--------|--------|
| 1 | [testable, binary pass/fail] | MUST | — |
| 2 | [testable, binary pass/fail] | MUST | — |
| 3 | [testable, binary pass/fail] | SHOULD | — |
| 4 | [testable, binary pass/fail] | SHOULD | — |
| 5 | [testable, binary pass/fail] | NICE | — |

Each criterion must be something you can TEST, not just check.

**Weight rules:**
- **MUST**: ALL must pass — automatic FAIL if any fails
- **SHOULD**: ≥50% must pass
- **NICE**: bonus, does not affect verdict

---

## Outcome Criteria (system state after)

| # | Criterion | Weight | Result |
|---|-----------|--------|--------|
| 1 | [system state check, binary pass/fail] | MUST | — |
| 2 | [system state check, binary pass/fail] | MUST | — |
| 3 | [system state check, binary pass/fail] | SHOULD | — |
| 4 | [system state check, binary pass/fail] | NICE | — |

Each criterion must be something you can TEST, not just check.

**Weight rules:**
- **MUST**: ALL must pass — automatic FAIL if any fails
- **SHOULD**: ≥50% must pass
- **NICE**: bonus, does not affect verdict

---

### Scoring Rules

1. **MUST gate**: If ANY MUST criterion fails → **VERDICT: FAIL** (no further scoring needed)
2. **SHOULD gate**: If <50% of SHOULD criteria pass → **VERDICT: FAIL**
3. **Pass**: If all MUSTs pass AND ≥50% of SHOULDs pass → **VERDICT: PASS**
4. **NICE**: Pure informational — count passed NICE criteria but never influence verdict
5. **Score formula**: `(passed_must + passed_should + passed_nice) / total_criteria × 100%`
6. Record score in Quality Log alongside pass@k results

---

## Validation Commands

| What | Command | Expected |
|------|---------|-----------|
| File compiles | `python -m py_compile [path]` | 0 |
| Tests pass | `pytest [path] -v` | PASS |
| Secrets OK | `grep -r "password\|secret" [path]` | no hardcoded |

---

## Quality Dimensions

| Dimension | Threshold | Result |
|-----------|-----------|--------|
| Correctness | 100% | — |
| Pattern Compliance | ≥3/4 | — |
| No Regressions | 100% | — |
| Data Integrity | 100% | — |

---

## Risks

- What could break
- How to rollback

---

## Files to Change

| File | Action | Why |
|------|--------|-----|
| `src/x.py` | create/modify | reason |
| `src/y.py` | create/modify | reason |

---

## Correction Loop

- Max 3 cycles per criterion
- After 3 failures: STOP and ask user

---

## Sign-off

- [ ] User approved contract
- [ ] Executor implemented
- [ ] code-reviewer verified
- [ ] Quality Log updated (with pass@k results)

---

## Git Commit

- [ ] Files staged and committed
- [ ] Commit message follows format
- [ ] No secrets detected (pre-commit hook)
- [ ] Branch: [branch name]

### Commit Details
- **Branch:** `master` or `sprint/nome-do-objetivo`
- **Commit Message:** 
  ```
  feat(scope): description — phase N/M [PASS: X%]
  ```
- **Files Included:**
  - Contract file
  - Code changes
  - GOAL_DECOMPOSITION.md (if phased)
