# Quality Tracking Reference

Quality tracking mechanisms: Quality Log, Calibration Log, Saturation Detection, and Harness Audit.

## Quality Log

Record score after each validated sprint.

**Format:**
```
| Date | Contract | Score | Must | Should | Nice | Correctness | Patterns | Regressions | Data | Verdict |
|------|----------|-------|------|--------|------|-------------|----------|-------------|------|---------|
```

**Fields:**
- **Score**: Weighted aggregate — Must×60% + Should×30% + Nice×10%
- **Must/Should/Nice**: Pass counts (e.g., 4/4, 2/2)
- **Correctness**: All criteria met, code compiles
- **Patterns**: Naming, structure, imports follow conventions (≥3/4)
- **Regressions**: Previously-passing tests still pass
- **Data**: Ports correct (7688/7475), no cross-case leakage
- **Verdict**: PASS / FAIL / PARTIAL

---

## Trials (pass@k)

Non-deterministic agents produce different outputs on each run. Contracts support **pass@k** evaluation:

- **Default:** `trials: 3` in contract header
- A criterion passes if it succeeds in ≥1 of k trials (pass@k)
- For deterministic changes (refactors, config), `trials: 1` is sufficient

**Example contract header:**
```yaml
trials: 3
pass_threshold: 2/3
```

---

## Severity Levels

Each criterion has a weight that determines its blocking power.

| Level | Meaning | Examples |
|-------|---------|----------|
| **MUST** | Blocking — must pass for contract to succeed | `File compiles without errors`, `All tests pass` |
| **SHOULD** | Important — contract succeeds but flags improvement | `Follows naming convention`, `Code coverage ≥80%` |
| **NICE** | Optional — tracked but never blocks | `Includes docstrings`, `Error messages are user-friendly` |

### Scoring Rules

1. **MUST gate**: If ANY MUST criterion fails → **VERDICT: FAIL**
2. **SHOULD gate**: If <50% of SHOULD criteria pass → **VERDICT: FAIL**
3. **NICE**: Pure bonus — never influences verdict
4. **Score formula**: `(passed_must + passed_should + passed_nice) / total_criteria × 100%`

---

## Good vs Bad Criteria

| Good ✅ | Bad ❌ |
|--------|--------|
| `File compiles without errors` | `Code looks good` |
| `Function X accepts a, b, c and returns dict` | `Function works correctly` |
| `All tests in test_file.py pass` | `Tests pass` |

---

## Saturation Detection

If 3+ consecutive contracts score 100%, the evaluation has saturated — no signal for improvement.

**What to do:**
- Criteria are too easy → make them harder
- Add SHOULD/NICE criteria that stretch quality
- Introduce adversarial test cases or edge-case coverage
- Consider increasing contract scope

**Rule:** Review Quality Log before writing a new contract. If recent entries show consistent 100%, raise the bar.

---

## Evaluator Calibration

Track divergences between code-reviewer judgment and user judgment to tune quality criteria.

### Calibration Workflow

```
1. code-reviewer reviews → records result in Quality Log
2. If user disagrees with verdict → user flags divergence
3. code-reviewer appends entry to CALIBRATION_LOG.md
4. Before next contract → Planner reads CALIBRATION_LOG
5. Planner adjusts criteria (strengthen/relax/simplify)
6. Run 3 sprints → mark action as VALIDATED if no recurrence
```

### When to Calibrate

- After any sprint where user manually overrides code-reviewer
- Every 5 sprints as routine review
- When Quality Log shows systematic bias (all PASS or all FAIL)

### Calibration Actions

| Divergence Type | Action |
|-----------------|--------|
| False positive (reviewer PASS, user FAIL) | Strengthen criterion or add validation command |
| False negative (reviewer FAIL, user PASS) | Simplify criterion or downgrade MUST → SHOULD |
| Same criterion fails 3+ times | Consider if criterion is load-bearing or noise |

---

## Harness Audit

Every component in the harness encodes an assumption about what the model cannot do on its own. Audit periodically to find overhead.

### Audit Workflow

```
1. Read Quality Log — last 5 sprints
2. Review Criterion Effectiveness table
3. Identify components that never caught issues
4. Remove one component from next contract
5. Track if quality drops
6. If no drop → remove permanently
7. If quality drops → restore component
```

### Effectiveness Classification

| Fail Rate | Classification | Action |
|-----------|----------------|--------|
| >30% | CRITICAL | Keep — load-bearing |
| 10-30% | USEFUL | Keep — catches real regressions |
| 1-10% | MARGINAL | Consider merging with another criterion |
| 0% (5+ sprints) | CANDIDATE FOR REMOVAL | Test removing in next sprint |

### Audit Rules

- Remove ONE component at a time (never multiple)
- Run at least 3 sprints before declaring a component unnecessary
- If a removed component was actually needed, restore immediately
- Record all audit decisions in CALIBRATION_LOG.md