# CONTRACT — [Feature Name]

**Date:** YYYY-MM-DD
**Planner:** [name]
**Status:** DRAFT → NEGOTIATING → APPROVED → IMPLEMENTING → VALIDATED

---

## Scope

[What files change and why. Be specific about the goal.]

---

## Done When

- [ ] Criterion 1 — [testable, binary pass/fail]
- [ ] Criterion 2 — [testable, binary pass/fail]
- [ ] Criterion N — [testable, binary pass/fail]

Each criterion must be something you can TEST, not just check.

---

## Validation Commands

| What | Command | Expected |
|------|---------|-----------|
| File compiles | `python -m py_compile [path]` | 0 |
| Tests pass | `pytest [path] -v` | PASS |
| Ports OK | `grep -r "7474\|7687" [path]/` | (empty) |
| Secrets OK | `grep -r "password\|secret" [path]/` | no hardcoded |

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
- [ ] Validator verified
- [ ] Quality Log updated