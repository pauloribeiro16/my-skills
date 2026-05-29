---
name: sprint-orchestrator
description: "Orchestrate complex multi-step tasks using Anthropic Harness: pre-flight checks, subagent dispatch, correction loops, quality gates. Use for 3+ file changes, multi-phase work, or subagent coordination. Trigger phrases: orchestrate sprint, manage complex task, coordinate subagents, multi-phase workflow, start a sprint"
---

# Sprint Orchestrator Skill

Orchestrate complex tasks using **generator-evaluator separation** with binary evaluation and correction loops.

## When to Use

- Tasks with 3+ file changes
- Multi-phase work (understand → implement → validate)
- Tasks requiring subagent coordination
- When resuming from a previous session
- Before writing a sprint contract

## Core Flow

```
PRE-FLIGHT → EXPLORE → CONTRACT → APPROVE → EXECUTE → VALIDATE → DELIVER
```

| Phase | What | Details |
|-------|------|---------|
| 0 | Pre-flight | Check Python, venv, .env, git, AGENTS.md |
| 1 | Explore | Launch code-explorer if codebase unfamiliar |
| 2 | Contract | Write CONTRACT.md with validation commands |
| 3 | Approve | Get user approval (max 3 rounds) |
| 4 | Execute | Launch Executor subagent |
| 5 | Validate | Launch code-reviewer subagent |
| 6 | Deliver | Quality Log + SESSION_STATE update |

## Subagent Dispatch

| Situation | Subagent | Purpose |
|-----------|----------|---------|
| Unfamiliar code | **code-explorer** | Fast reconnaissance |
| Implement contract | **Executor** | Contract-driven, sequential |
| Verify implementation | **code-reviewer** | Independent PASS/FAIL |

**Rule: Planner NEVER implements or verifies. Planner only delegates.**

## Correction Loop

```
Executor implements → code-reviewer verifies
                        │
              ┌────┴────┐
              │         │
            PASS      FAIL
              │         │
              ▼         ▼
           next    Executor fixes
           sprint        │
                         ▼
                   attempt++ (max 3)
```

After each PASS: **COMMIT immediately** before next sprint.

## NEVER Do This

| Anti-pattern | Correction |
|--------------|------------|
| Implement directly | Dispatch Executor |
| Verify own work | Dispatch code-reviewer |
| Skip pre-flight | Check env first |
| Launch without contract | Write CONTRACT.md first |
| Skip commit between sprints | `git add + commit` |

## Resources

- `sprint-contract/SKILL.md` — Contract creation with validation tiers
- `sprint-contract/templates/CONTRACT.md` — Contract template
- `sprint-contract/templates/QUALITY_LOG.md` — Quality log format
- `sprint-contract/templates/SESSION_STATE.md` — Session state format

## Use When

You need systematic orchestration with clear gates and independent verification — not just "do this task."