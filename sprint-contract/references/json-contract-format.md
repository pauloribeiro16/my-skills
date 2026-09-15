# JSON Contract Format Reference

The canonical contract format is **JSON**, not Markdown. Anthropic's long-running agents research found that "we landed on using JSON for this, as the model is less likely to inappropriately change or overwrite JSON files compared to Markdown files."

## Default-FAIL Contract

The core principle: **every criterion starts `false`. The agent cannot mark it passing without opening evidence first.**

```
WRONG (Markdown, implicit):
| # | Criterion | Result |
|---|-----------|--------|
| 1 | compiles  | —      |   ← empty, agent fills "PASS" freely

CORRECT (JSON, default-FAIL):
{
  "criteria": [
    {"id": "C1", "description": "...", "weight": "MUST", "passed": false, "evidence": null}
  ]
}
                                          ↑ starts false, agent must OPEN evidence to flip
```

### Why Default-FAIL?

Agents will mark a feature "passing" after a unit test or a curl when the UI is visibly broken. Asking nicely in the prompt doesn't reliably stop this. The harness makes "done" structural:

1. Every criterion has `"passed": false` by default
2. The agent can ONLY flip it to `true` after opening evidence (Read tool on a result file)
3. No evidence opened → criterion stays `false` → sprint fails

## Contract File Structure

```json
{
  "contract_id": "SC-2026-01",
  "feature": "Feature Name",
  "date": "YYYY-MM-DD",
  "planner": "[name]",
  "spec_file": "SPEC.md",
  "status": "DRAFT",
  "phase": "1 of 3",
  "depends_on": "Phase 0",
  "parallel_group": "G0",
  "parent_goal": "GOAL_DECOMPOSITION.md",
  "trials": 3,
  "pass_threshold": "2/3",
  "scope": "[What files change and why]",
  "criteria": [
    {
      "id": "C1",
      "description": "[Testable, binary PASS/NEEDS_WORK]",
      "weight": "MUST",
      "tier": 3,
      "test_command": "python -c \"from m import f; assert f(x) == expected\"",
      "expected": "[Exact output or behavior]",
      "verdict": "PENDING",
      "passed": false,
      "evidence": null,
      "attempts": 0
    }
  ],
  "quality_dimensions": [
    {"name": "Correctness", "threshold": "100%", "result": null}
  ],
  "risks": ["[What could break]", "[How to rollback]"],
  "files_to_change": [
    {"file": "src/x.py", "action": "create/modify", "why": "reason"}
  ],
  "correction_loop": {"max_cycles": 3, "current_cycle": 0},
  "sign_off": {
    "user_approved": false,
    "generator_implemented": false,
    "evaluator_verified": false,
    "quality_log_updated": false
  }
}
```

## Evidence Enforcement

The agent cannot claim success it hasn't observed. The only evidence that counts is a file matching patterns (screenshots, console logs, result files), and the agent must **Read** it before flipping `"passed": true`.

### Enforcement Rule

```
For each criterion C in contract:
  IF C.passed == true AND C.evidence == null:
    → REJECT: "No evidence opened for C"
  IF C.evidence != null AND not Read(C.evidence):
    → REJECT: "Evidence file not opened with Read tool"
  ELSE:
    → Accept C.passed value
```

## Per-Criterion Status (not global machine)

Anthropic tracks `"passed": false` → `"passed": true` **per criterion**, not a global status flow.

```
WRONG (global status machine):
  DRAFT → NEGOTIATING → APPROVED → IMPLEMENTING → VALIDATED

CORRECT (per-criterion):
  C1: passed=false → true
  C2: passed=false → true
  C3: passed=false (still failing)
  → Sprint verdict = NEEDS_WORK until ALL MUST criteria = true
```

## Scoring Rules

1. **MUST gate**: If ANY MUST criterion has `passed: false` → **VERDICT: NEEDS_WORK**
2. **SHOULD gate**: If `<50%` of SHOULD criteria have `passed: true` → **VERDICT: NEEDS_WORK**
3. **Pass**: If all MUSTs `true` AND `≥50%` SHOULDs `true` → **VERDICT: PASS**
4. **NICE**: Pure informational — count passed NICE but never influence verdict
5. **Score**: `(passed_must + passed_should + passed_nice) / total × 100%`

## Writing Good Criteria

| Good ✅ | Bad ❌ |
|------|------|
| `"test_command": "python -c \"from m import f; r=f(); assert r['ok']\""` | `"test_command": "python -m py_compile m.py"` (syntax only) |
| `"tier": 3` for MUST (behavioral) | `"tier": 1` for MUST (syntax only) |
| `"evidence": "test_output.log"` opened via Read | `"evidence": null` but `"passed": true` |

## Generator Self-Assessment (Optional)

Anthropic's harness has the Generator self-assess before Evaluator handoff. This is OPTIONAL — the Evaluator is the authoritative grade.

```json
{
  "generator_self_assessment": {
    "thoughts": "[What was built and why]",
    "confidence": "high|medium|low",
    "open_questions": ["..."]
  }
}
```

## Conversion from Markdown

If you have an old Markdown `CONTRACT.md`:

1. Each `| # | Criterion | Weight | Result |` row → one object in `"criteria"` array
2. Set `"passed": false` for all (default-FAIL)
3. Add `"tier"`, `"test_command"`, `"expected"`, `"verdict": "PENDING"`
4. `"evidence": null` until opened
5. Quality Dimensions → `"quality_dimensions"` array
6. Risks → `"risks"` array
7. Files to Change → `"files_to_change"` array

## Integration with Other References

- **Spec-driven**: `SPEC.md` maps to contract criteria via `"spec_file"` field
- **Parallel execution**: `"parallel_group"` field drives group assignment
- **Validation tiers**: `"tier"` field (1-4) determines rigor
- **Fresh-context evaluator**: See `references/fresh-context-evaluator.md`
