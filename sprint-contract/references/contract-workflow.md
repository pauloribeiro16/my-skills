# Contract Workflow Reference

Detailed workflow for executing a sprint contract.

## Standard Contract Workflow

```
1. Planner writes CONTRACT.md (from template)
2. User approves (max 3 negotiation rounds)
3. Executor reads CONTRACT.md
4. Executor implements criteria sequentially
5. code-reviewer verifies each criterion
   - If FAIL → Executor fixes → code-reviewer re-checks (max 3)
   - If still FAIL after 3 → STOP and ask user
6. After all PASS → code-reviewer appends to QUALITY_LOG.md
```

## Negotiation Rounds

| Round | Action |
|-------|--------|
| 1 | Planner writes initial contract → presents to user |
| 2 | User requests changes (if any) |
| 3 | Final changes → user approves |

Max 3 rounds. After that, present final version for approval or abandonment.

## Correction Loop

```
Executor implements criterion
         │
         ▼
    code-reviewer verifies
         │
    ┌────┴────┐
    │         │
  PASS      FAIL
    │         │
    ▼         ▼
  next   classify error
 criterion   │
             ├─→ IMPORT_ERROR
             ├─→ RUNTIME_ERROR
             ├─→ FILE_MISSING
             ├─→ SYNTAX_ERROR
             └─→ LOGIC_ERROR
             │
             ▼
       Executor fixes
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

**Max 3 correction cycles per criterion. After 3 failures: STOP and ask user for guidance.**