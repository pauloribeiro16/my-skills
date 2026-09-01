# CONTRACT — [Feature Name]

**Contract ID:** SC-YYYY-NN
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

Validation commands are grouped by **tier** — the tier determines which criteria weight requires this level of rigor.

| Tier | What it tests | When Required |
|------|---------------|---------------|
| **T1** | Syntax — file compiles | NICE criteria minimum |
| **T2** | Import & Runtime — module loads, objects instantiate | SHOULD criteria minimum |
| **T3** | Behavioral — function output, error handling, state changes | MUST criteria minimum |
| **T4** | Integration — E2E smoke tests with mock data | SHOULD/NICE for complex features |

### Tier 1 — Syntax

| What | Command | Expected |
|------|---------|----------|
| File compiles | `python -m py_compile [path]` | exit 0 |

### Tier 2 — Import & Runtime

| What | Command | Expected |
|------|---------|----------|
| Module imports | `python -c "from module import func"` | exit 0 |
| Object instantiates | `python -c "from module import X; X()"` | exit 0 |
| Function callable | `python -c "from module import f; assert callable(f)"` | exit 0 |

### Tier 3 — Behavioral (MUST criteria)

| What | Command | Expected |
|------|---------|----------|
| Function returns expected type | `python -c "from m import f; r=f(); assert isinstance(r, dict)"` | exit 0 |
| Error captured in state | `python -c "from m import Node; s={'errors':[]}; Node(s); assert s['errors']"` | exit 0 |
| Output matches expected | `python -c "from m import f; assert f(x)==expected"` | exit 0 |

### Tier 4 — Integration

| What | Command | Expected |
|------|---------|----------|
| Graph builds | `python -c "from m import build_graph; g=build_graph(); assert 'node' in g.nodes"` | exit 0 |
| Graph invokes | `python -c "from m import build_graph; g=build_graph(); g.invoke(state)"` | no exception |
| Smoke test with mock | `python -c "from m import run; result=run(mock_state); assert 'output' in result"` | exit 0 |

### Validation Tier Rules

1. **MUST criterion** → Tier 3 minimum (behavioral)
2. **SHOULD criterion** → Tier 2 minimum (import/runtime)
3. **NICE criterion** → Tier 1 acceptable (syntax only)
4. If a criterion cannot be tested with a command → **rewrite the criterion** until it can

### Writing Good Validation Commands

| Good ✅ | Bad ❌ |
|--------|--------|
| `python -c "from m import f; r=f(); assert r['ok']"` | `python -m py_compile m.py` (only tests syntax) |
| `python -c "g=build_graph(); assert 'node' in g.nodes"` | `grep "def build_graph" m.py` (only checks existence) |
| `python -c "Node(state); assert state['errors']"` | "Error handling exists" (not testable) |

### Validation Command Template

For each criterion, write this:

```
## [Criterion name]
- **Tier:** [1/2/3/4]
- **Command:** [exact command to run]
- **Expected:** [exact output or behavior]
- **Pass condition:** [binary yes/no]
```

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
- [ ] SESSION_STATE.md updated (if sprint >1 day)

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
