# Trials & pass@k Reference

## Why Trials

Non-deterministic agents (LLM-based) produce different outputs on each run. A single run passing or failing may be due to luck. Trials account for this variance.

## Default Configuration

```yaml
trials: 3
pass_threshold: 2/3
```

- **pass@k:** A criterion passes if it succeeds in ≥1 of k trials
- **pass@1, pass@2, pass@3:** Record each trial result individually
- **Majority verdict:** Final verdict requires ≥ pass_threshold proportion of trials to pass

## When to Adjust Trials

| Scenario | Recommended Trials | Reason |
|----------|-------------------|--------|
| Refactors, config, deterministic code | 1 | No variance expected |
| Standard feature implementation | 3 | Balances cost vs reliability |
| Investigating flaky failures | 5 | Identifies root cause |
| Critical correctness (security, data) | 3 | More trials = higher confidence |

## Recording Results

In the Quality Log, record per-criterion:

```
| Criterion | Trial 1 | Trial 2 | Trial 3 | pass@k | Verdict |
|-----------+---------+---------+---------+--------+---------|
| Output    | PASS    | PASS    | FAIL    | 2/3    | PASS    |
| Outcome   | FAIL    | PASS    | PASS    | 2/3    | PASS    |
```

## Scoring with Trials

1. Run all criteria through k trials
2. Each criterion gets a pass@k score (e.g., 2/3)
3. A criterion passes if pass@k ≥ 1
4. Apply MUST/SHOULD/NICE weight rules using the criterion verdict
5. Overall score = `(passed_must + passed_should + passed_nice) / total_criteria × 100%`

## Eval Harness Integration

If your project has a trial-aware eval runner:

```bash
# Single task with 3 trials
<eval_runner> --task <task_id> --trials 3 --verbose
```

The eval harness should:
- Run each criterion k times identically
- Record individual pass@k per criterion
- Aggregate into overall sprint score
- Log results to the Quality Log
