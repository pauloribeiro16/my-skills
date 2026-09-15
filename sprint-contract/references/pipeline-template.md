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

- **Dependency-driven** — build graph, detect parallel opportunities
- **S1 must PASS** before S2 starts (if S2 depends on S1)
- **Max 5 sprints** per pipeline
- Each sprint should be independently verifiable

### Execution Modes

| Mode | When | Example |
|------|------|---------|
| **Sequential** | Linear chain: S1→S2→S3 | All sprints depend on previous |
| **Parallel groups** | Mixed deps: S1→{S2,S3}→S4 | S2 and S3 are independent |
| **Fully parallel** | No deps: {S1,S2,S3,S4} | All sprints independent |

Full reference: `references/parallel-execution.md`

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
- **Status:** ✅ PASS / ❌ NEEDS_WORK / ⏳ IN PROGRESS
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

### Scenario: Add Langfuse Tracing (Parallel)

```
Sprint S1: Trace ID Propagation
├── Scope: Add trace_id to state, create trace in agent
├── Files: core/agent/graph/state.py, core/agent/agent.py
├── Parallel Group: G0
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
├── Depends On: S1
├── Parallel Group: G1
├── Criteria:
│   ├── nodes.py compiles
│   ├── cypher_generation span created
│   ├── cypher_execution span created
│   └── answer_generation span created
└── Validation:
    ├── python -m py_compile core/agent/graph/nodes.py
    ├── Run agent and verify trace in Langfuse UI
    └── Check span hierarchy

Sprint S3: Refactor prompts.py
├── Scope: Extract prompt templates, remove duplication
├── Files: core/agent/graph/prompts.py
├── Depends On: NONE (independent)
├── Parallel Group: G0
├── Criteria:
│   ├── prompts.py compiles
│   ├── No duplicate prompt strings
│   └── All imports work
└── Validation:
    ├── python -m py_compile core/agent/graph/prompts.py
    └── python -c "from core.agent.graph.prompts import *"

Sprint S4: Scores and Cleanup
├── Scope: Centralize get_langfuse_client, remove dead code
├── Files: core/agent/tracing.py, core/eval/run_eval.py,
│          core/eval/minimax_judge.py
├── Depends On: S1
├── Parallel Group: G1
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

### Dependency Graph

```
S1 ──→ S2 ──┐
 │           │
 └──→ S4 ───┘
       
S3 (independent)
```

### Parallel Execution Plan

```
⚠️ RULE: Generators write code, Evaluators read code.
   NEVER launch Evaluator before Generator finishes.

Group G0: [S1, S3]     ← PARALLEL (no deps)
  STEP A: EXECUTE
  ├─ Generator(S1)  ┐
  ├─ Generator(S3)  ├─ WAIT ALL finish
  └────────────────┘
  STEP B: VALIDATE
  ├─ Evaluator(S1)  ┐
  ├─ Evaluator(S3)  ├─ WAIT ALL finish
  └────────────────┘
  STEP C: COMMIT

Group G1: [S2, S4]     ← PARALLEL (both depend on G0)
  STEP A: EXECUTE
  ├─ Generator(S2)  ┐
  ├─ Generator(S4)  ├─ WAIT ALL finish
  └────────────────┘
  STEP B: VALIDATE
  ├─ Evaluator(S2)  ┐
  ├─ Evaluator(S4)  ├─ WAIT ALL finish
  └────────────────┘
  STEP C: COMMIT
```

### Time Savings

```
Sequential: S1→S2→S3→S4 = 4 × 10min = 40 min
Parallel:   G0(10) + G1(10) = 20 min
Saved: ~20 min (50%)
```

## Pipeline Approval Process

1. **Planner writes ALL contracts** (S1, S2, S3...)
2. **Build dependency graph** — map which sprints depend on which
3. **Assign parallel groups** — independent sprints in same group
4. **Check for file conflicts** — same file in same group = force sequential
5. **Present COMPLETE pipeline** to user with dependency graph
6. **User approves ALL** or requests changes
7. **Execute by group** — parallel sprints in group, sequential between groups
8. **Update user after each group** — don't wait until the end

## User Presentation Format

```
## Multi-Sprint Pipeline Ready

### Overview
[One paragraph describing the overall goal]

### Dependency Graph
S1 ──→ S2 ──┐
 │           │
 └──→ S4 ───┘
S3 (independent)

### Sprints
| # | Name | Files | Dependencies | Group | Est. Time |
|---|------|-------|-------------|-------|-----------|
| S1 | Foundation | 2 files | None | G0 | 5 min |
| S2 | Core | 1 file | S1 | G1 | 10 min |
| S3 | Refactor | 1 file | None | G0 | 10 min |
| S4 | Cleanup | 3 files | S1 | G1 | 10 min |

### Parallel Groups
| Group | Sprints | Execution | Conflict Check |
|-------|---------|-----------|----------------|
| G0 | S1, S3 | Parallel Exec → Sequential Validate → Commit | No file overlap |
| G1 | S2, S4 | Parallel Exec → Sequential Validate → Commit | No file overlap |

> **Rule:** Within each group: Generators run parallel → WAIT → Evaluators run parallel → WAIT → Commit. Never launch Evaluator before Generator finishes.

### Total
- **Files:** 7 files
- **Est. Time:** 20 min (vs 40 min sequential)
- **Sprints:** 4 (2 parallel groups)
- **Time saved:** ~50%

Approve pipeline? (yes / no / modify)
```

## After Each Group

```
## Group G0 Complete ✅

### Sprints in Group
| Sprint | Status | Files | Time |
|--------|--------|-------|------|
| S1 | PASS | 2 changed | 4 min |
| S3 | PASS | 1 changed | 3 min |

### Quality
| Sprint | Correctness | Pattern | Regressions | Data Integrity |
|--------|-------------|---------|-------------|----------------|
| S1 | 100% | 4/4 | 100% | 100% |
| S3 | 100% | 3/4 | 100% | 100% |

### Commit
- Hash: [hash]
- Message: feat(tracing): group 0 — S1 Trace ID + S3 Refactor [PASS: 100%]

### Next
Starting Group G1 (S2, S4) — launching 2 parallel Generators...
[Press Ctrl+C to pause between groups]
```
