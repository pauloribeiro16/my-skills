# Contract Workflow Reference

Detailed workflow for executing a sprint contract.

## Standard Contract Workflow

```
1. Planner writes CONTRACT.json (from template — default-FAIL: all criteria start passed:false)
2. Evaluator reviews contract UPFRONT (fresh context):
   - Are test_command(s) adequate (Tier 3 for MUST, Tier 2 for SHOULD)?
   - Are criteria clearly falsifiable and measurable?
   - Negotiate fixes with the Planner BEFORE any code is written
3. User approves (max 3 negotiation rounds)
4. Generator reads CONTRACT.json (fresh context, separate from the Evaluator)
5. Generator implements criteria sequentially
6. Evaluator verifies each criterion (fresh context — never saw the Generator's work)
   - If NEEDS_WORK → Generator fixes → Evaluator re-checks (max 3)
   - If still NEEDS_WORK after 3 → STOP and ask user
7. After all PASS → Evaluator appends to QUALITY_LOG.md
```

> **Why upfront Evaluator review?** Catching vague or untestable criteria before
> generation saves the most expensive resource: implementation time. The Evaluator
> negotiates *what should be true* and *how we will measure it* up front.

## Negotiation Rounds

| Round | Action |
|-------|--------|
| 1 | Planner writes initial contract → presents to user |
| 2 | User requests changes (if any) |
| 3 | Final changes → user approves |

Max 3 rounds. After that, present final version for approval or abandonment.

## Correction Loop

```
Generator implements criterion
         │
         ▼
    Evaluator verifies
         │
    ┌────┴────┐
    │         │
  PASS    NEEDS_WORK
    │         │
    ▼         ▼
  next   classify error
 criterion   │
             ├─→ IMPORT_ERROR
             ├─→ RUNTIME_ERROR
             ├─→ FILE_MISSING
             ├─→ SYNTAX_ERROR
             ├─→ LOGIC_ERROR
             ├─→ PORT_ERROR
             └─→ SECRET_ERROR
             │
             ▼
       Generator fixes
             │
             ▼
       attempt++
             │
       ┌─────┴─────┐
       │           │
   attempt < 3  attempt = 3
       │           │
       ▼           ▼
    continue    STOP
               (ask user)
```

**Max 3 correction cycles per criterion. After 3 NEEDS_WORK verdicts: STOP and ask user for guidance.**
