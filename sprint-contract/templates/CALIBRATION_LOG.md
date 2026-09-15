# CALIBRATION_LOG.md

Records divergences between Evaluator judgment and user judgment.
Used to tune quality criteria over time.

---

## Format

Evaluator appends entries. User adds corrections. Planner reads before writing new contracts.

---

## Log

| Date | Contract | Evaluator | User | Criterion | Root Cause | Action | Status |
|------|----------|----------|------|-----------|------------|--------|--------|
| YYYY-MM-DD | Feature Name | PASS | NEEDS_WORK | C3 — Code coverage | Missed edge case | Lower threshold to 75% | OPEN |
| YYYY-MM-DD | Feature Name | NEEDS_WORK | PASS | C5 — Naming convention | Overly strict rule | Downgrade MUST → SHOULD | RESOLVED |

---

## Fields Explained

| Field | Description |
|-------|-------------|
| **Evaluator** | Evaluator verdict (PASS / NEEDS_WORK) |
| **User** | User actual verdict (PASS / NEEDS_WORK) |
| **Criterion** | Which contract criterion diverged |
| **Root Cause** | Why the Evaluator was wrong |
| **Action** | Proposed change to criteria or validation |
| **Status** | OPEN → RESOLVED → VALIDATED |

---

## Status Rules

- **OPEN:** Divergence identified, action proposed but not yet tested
- **RESOLVED:** Action implemented in a new contract
- **VALIDATED:** Action tested in 3+ sprints without recurrence

---

## Patterns to Watch

| Pattern | What it means | Suggested action |
|---------|---------------|------------------|
| Same criterion → 3+ false positives | Too lenient | Strengthen MUST or add validation command |
| Same criterion → 3+ false negatives | Too strict | Simplify or downgrade MUST → SHOULD |
| All evaluators PASS, user FAILs | Systemic leniency | Add stricter MUST criteria |
| All evaluators NEEDS_WORK, user PASSes | Systemic strictness | Review if criteria are realistic |

---

## Recent Entries

<!-- Add new entries above this line -->

| Date | Contract | Evaluator | User | Criterion | Root Cause | Action | Status |
|------|----------|----------|------|-----------|------------|--------|--------|

