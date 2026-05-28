# QUALITY_LOG.md

**Format:** code-reviewer appends after each validated contract.

---

## Log

| Date | Contract | Score | Must | Should | Nice | Correctness | Patterns | Regressions | Data | Verdict |
|------|----------|-------|------|--------|------|-------------|----------|-------------|------|---------|
| YYYY-MM-DD | Feature Name | 85 | 4/4 | 2/2 | 1/1 | 100% | 4/4 | 100% | 100% | PASS |

---

## Quality Dimensions Explained

| Dimension | Threshold | How to Verify |
|-----------|-----------|---------------|
| Score | ≥80 | Weighted aggregate: Must×60% + Should×30% + Nice×10% |
| Must | 100% | Hard requirements — all must pass |
| Should | ≥80% | Important but non-blocking criteria |
| Nice | ≥50% | Optional polish and improvements |
| Correctness | 100% | All contract criteria met, compilation returns 0 |
| Pattern Compliance | ≥3/4 | Naming, structure, imports follow conventions |
| No Regressions | 100% | Previously-passing tests still pass |
| Data Integrity | 100% | No data corruption, ports consistent |

---

## Saturation Tracking

Tracks whether quality criteria remain challenging enough.

| Metric | Value |
|--------|-------|
| Consecutive PASS @ 100% Score | 0 |
| Saturation Threshold | 3 |
| Status | — |

**Rules:**
- Increment counter after each PASS with 100% Score
- Reset counter on any non-100% Score or non-PASS verdict
- When counter reaches threshold: **"Consider adding harder criteria"**

---

## Verdict Rules

- **PASS:** ALL criteria met, all dimensions at threshold
- **FAIL:** Any criterion fails, any dimension below threshold
- **PARTIAL:** Some criteria met, requires discussion with user

---

## Example Entry

```
| 2026-05-25 | LLM Client Abstraction | 100 | 4/4 | 2/2 | 1/1 | 100% | 4/4 | 100% | 100% | PASS |
```

---

## Criterion Effectiveness

Tracks which criteria actually catch issues. Used by Harness Audit (see SKILL.md) to identify overhead.

| Criterion | Times Checked | Times Failed | Fail Rate | Classification |
|-----------|---------------|--------------|-----------|----------------|
| File compiles | 12 | 0 | 0% | CANDIDATE FOR REMOVAL |
| No hardcoded ports | 12 | 3 | 25% | LOAD-BEARING |
| Tests pass | 12 | 5 | 42% | CRITICAL |
| Naming convention | 8 | 0 | 0% | CANDIDATE FOR REMOVAL |

**Classification rules:**
- **CRITICAL** (>30%): Always catches real issues — never remove
- **USEFUL** (10-30%): Catches regressions — keep
- **MARGINAL** (1-10%): Rarely triggers — consider merging
- **CANDIDATE FOR REMOVAL** (0% for 5+ sprints): Pure overhead — test removing

---

## Recent Entries

<!-- Add new entries above this line -->

| Date | Contract | Score | Must | Should | Nice | Correctness | Patterns | Regressions | Data | Verdict |
|------|----------|-------|------|--------|------|-------------|----------|-------------|------|---------|
