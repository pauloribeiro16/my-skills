# Multi-Sprint Pipeline Template

Use this template when decomposing work into multiple sequential sprints.

## Pipeline Structure

```
execution/
├── CONTRACT_S1.md          ← Sprint 1: Foundation
├── CONTRACT_S2.md          ← Sprint 2: Core Implementation
├── CONTRACT_S3.md          ← Sprint 3: Integration & Polish
└── QUALITY_LOG.md          ← Updated after each sprint
```

## Sprint Dependency Rules

```
S1 ──→ S2 ──→ S3 ──→ S4 ──→ S5
  │      │      │      │      │
  └──────┴──────┴──────┴──────┘
         Must PASS before next
```

- **Sequential ONLY** — no parallel sprints
- **S1 must PASS** before S2 starts
- **Max 5 sprints** per pipeline
- Each sprint should be independently verifiable

## Decomposition Guidelines

### Sprint 1: Foundation
- Create new files/modules
- Add data structures, schemas, configs
- Set up infrastructure
- **Should not** modify existing logic

### Sprint 2: Core Implementation
- Add main functionality
- Modify existing files
- Implement contract criteria
- **Depends on** Sprint 1 infrastructure

### Sprint 3: Integration
- Wire components together
- Add error handling
- Update tests
- **Depends on** Sprint 2 functionality

### Sprint 4: Polish (optional)
- Refactoring
- Performance improvements
- Documentation
- **Depends on** Sprint 3 integration

### Sprint 5: Cleanup (optional)
- Remove dead code
- Final validation
- Update logs
- **Depends on** all previous sprints

## Pipeline Execution Log

Track progress in `execution/EXECUTION_STATE.md`:

```markdown
# Pipeline Execution Log

## Sprint S1 — [Name]
- **Status:** ✅ PASS / ❌ FAIL / ⏳ IN PROGRESS
- **Started:** YYYY-MM-DD HH:MM
- **Completed:** YYYY-MM-DD HH:MM
- **Files changed:** N files
- **Issues:** [none / list]

## Sprint S2 — [Name]
- **Status:** ⏳ PENDING
- **Blocked by:** S1
- **Estimated files:** N files
```

## Example Pipeline

### Scenario: Add Langfuse Tracing

```
Sprint S1: Trace ID Propagation
├── Scope: Add trace_id to state, create trace in agent
├── Files: core/agent/graph/state.py, core/agent/agent.py
├── Criteria:
│   ├── state.py compiles
│   ├── agent.py compiles
│   └── trace_id returned in result
└── Validation:
    ├── python -m py_compile core/agent/graph/state.py
    ├── python -m py_compile core/agent/agent.py
    └── grep -r "7474\|7687" core/ → empty

Sprint S2: Manual Spans in Nodes
├── Scope: Add spans in generate_and_execute() and generate_answer()
├── Files: core/agent/graph/nodes.py
├── Criteria:
│   ├── nodes.py compiles
│   ├── cypher_generation span created
│   ├── cypher_execution span created
│   └── answer_generation span created
└── Validation:
    ├── python -m py_compile core/agent/graph/nodes.py
    ├── Run agent and verify trace in Langfuse UI
    └── Check span hierarchy

Sprint S3: Scores and Cleanup
├── Scope: Centralize get_langfuse_client, remove dead code
├── Files: core/agent/tracing.py, core/agent/graph/prompts.py,
│          core/eval/run_eval.py, core/eval/minimax_judge.py
├── Criteria:
│   ├── All files compile
│   ├── Single get_langfuse_client definition
│   ├── No dead code in minimax_judge.py
│   └── Scores attach to traces
└── Validation:
    ├── python -m py_compile [all files]
    ├── grep -r "def get_langfuse_client" core/ → 1 match
    └── grep -r "log_scores_to_langfuse" core/ → 0 matches
```

## Pipeline Approval Process

1. **Planner writes ALL contracts** (S1, S2, S3...)
2. **Present COMPLETE pipeline** to user
3. **User approves ALL** or requests changes
4. **Execute sequentially** — S1 → S2 → S3
5. **Update user after each sprint** — don't wait until the end

## User Presentation Format

```
## Multi-Sprint Pipeline Ready

### Overview
[One paragraph describing the overall goal]

### Sprints
| # | Name | Files | Dependencies | Est. Time |
|---|------|-------|-------------|-----------|
| S1 | Foundation | 2 files | None | 5 min |
| S2 | Core | 1 file | S1 | 10 min |
| S3 | Integration | 4 files | S2 | 15 min |

### Total
- **Files:** 7 files
- **Est. Time:** 30 min
- **Sprints:** 3 sequential

Approve pipeline? (yes / no / modify)
```

## After Each Sprint

```
## Sprint S1 Complete ✅

### Result
- Status: PASS
- Files: 2 changed
- Time: 4 min

### Quality
- Correctness: 100%
- Pattern Compliance: 4/4
- No Regressions: 100%
- Data Integrity: 100%

### Next
Starting Sprint S2 in 30 seconds...
[Press Ctrl+C to pause between sprints]
```