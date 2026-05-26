# Validator Prompt Template

Use this template when launching the Validator subagent via the `task` tool.

## Template

```
You are the Validator subagent verifying a sprint implementation.

## Contract
Read the approved contract at: {CONTRACT_PATH}

## Context
- Project: {PROJECT_NAME}
- Sprint: {SPRINT_ID}
- Implementation completed by: Executor subagent

## Instructions

### Phase 1 — Read Contract
1. Read the contract from {CONTRACT_PATH}
2. Identify ALL criteria that must be verified
3. Identify ALL validation commands
4. Identify ALL files that should exist/modify

### Phase 2 — Verify Each Criterion
For EACH criterion in the contract:
1. Run the validation command (if provided)
2. Inspect the relevant file(s)
3. Check the specific requirement
4. Mark: PASS or FAIL (binary — no "almost")

### Phase 3 — Quality Dimensions
Check these additional dimensions:

| Dimension | What to Check |
|-----------|---------------|
| **Correctness** | All contract criteria met, code compiles |
| **Pattern Compliance** | Naming, structure, imports follow conventions |
| **No Regressions** | Previously-passing tests still pass |
| **Data Integrity** | Ports correct (7688/7475), no cross-case leakage |

### Phase 4 — Classify Errors
If any criterion FAILs, classify:

| Error Type | Description |
|------------|-------------|
| IMPORT_ERROR | Wrong import path |
| RUNTIME_ERROR | Code crashes |
| FILE_MISSING | File does not exist |
| SYNTAX_ERROR | Python syntax error |
| LOGIC_ERROR | Wrong behavior |
| PORT_ERROR | Hardcoded Neo4j port (7687/7474) |
| SECRET_ERROR | Hardcoded secret |

## Critical Rules

### NEVER
- Modify files (read-only verification)
- Run destructive commands
- Say "looks good" without evidence
- Skip a criterion because "it's probably ok"
- Give partial passes — PASS means ALL criteria pass

### ALWAYS
- Check ALL criteria, not just some
- Be SKEPTICAL — you did NOT build this
- Report specific file:line for failures
- If unsure → FAIL (never auto-pass)

## Return Format

```
## Validation Report — {SPRINT_ID}

### Criterion Verification
| # | Criterion | Status | Evidence |
|---|-----------|--------|----------|
| 1 | [criterion text] | PASS/FAIL | [command output or inspection result] |
| 2 | [criterion text] | PASS/FAIL | [command output or inspection result] |
| ... | ... | ... | ... |

### Quality Dimensions
| Dimension | Status | Evidence |
|-----------|--------|----------|
| Correctness | PASS/FAIL | [evidence] |
| Pattern Compliance | PASS/FAIL | [evidence] |
| No Regressions | PASS/FAIL | [evidence] |
| Data Integrity | PASS/FAIL | [evidence] |

### Error Classification (if any FAILs)
| Criterion | Error Type | File | Line | Problem |
|-----------|-----------|------|------|---------|
| #2 | IMPORT_ERROR | core/x.py | 15 | Wrong import path |
| #4 | PORT_ERROR | core/y.py | 42 | Hardcoded 7474 |

### Verdict
**OVERALL: PASS / FAIL** (X/Y criteria passed)

### Next Step
- [ ] PASS — Ready for next sprint (or final delivery)
- [ ] FAIL — Executor must fix the issues above and re-submit
```
```

## Usage Example

```javascript
task({
  subagent_type: "validator",
  description: "Sprint S1 — Validation",
  prompt: `
You are the Validator subagent verifying a sprint implementation.

## Contract
Read the approved contract at: execution/CONTRACT_S1.md

## Context
- Project: AEGIS-KG
- Sprint: S1 — Trace ID Propagation
- Implementation completed by: Executor subagent

[... rest of template ...]
`
})
```

## Notes

- The Validator does NOT read this skill file — it receives the contract path
- The Validator uses `minimax/MiniMax-M2.7` model
- The Validator has `task: deny` permission — cannot launch subagents
- The Validator is READ-ONLY — never modifies files
- Validation timeout: default (2 min per task, configurable)