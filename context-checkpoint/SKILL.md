---
name: context-checkpoint
description: "Use when conversation context exceeds 70% or before continuing long tasks. Prevents context anxiety, creates structured handoff for next session."
---

# Context Checkpoint Skill

Prevents context overflow and ensures continuity across sessions.

## When to Activate

- Context window above 70%
- Before a long task continuation
- When context feels cluttered
- Between major phases of work

## What to Do

### Step 1 — Write Session State

Create or update `SESSION_STATE.md` with:

```markdown
# SESSION_STATE — [date]

## Completed
- [x] Task A (file:line)
- [x] Task B (file:line)

## In Progress
- [ ] Task C — blocked by X
- [ ] Task D — in progress, half done

## Next Steps
1. Complete Task C (file:line)
2. Start Task D (target file)
3. Verify with code-reviewer

## Exact Continuation Point
File: [path/to/file.py]
Line: [line number]
Next action: [what to do next]

## Context Summary
- Working on: [what this part does]
- Key files: [list]
- Neo4j ports: 7688/7475 (if applicable)
- Current case: [case name if applicable]

## Handoff Notes
- Don't restart from scratch — read SESSION_STATE.md first
- Check SESSION_STATE.md for blocked tasks
- code-reviewer should verify before continuing
```

### Step 2 — Clear Context Path

Before continuing after checkpoint:
1. Read `SESSION_STATE.md`
2. Read the exact continuation point
3. Verify environment (venv, ports, etc.)
4. Continue from where you left off

### Step 3 — If Context Reset Required

If context must be fully cleared:
1. Read all relevant AGENTS.md files
2. Read `SESSION_STATE.md`
3. Read the continuation point file
4. Resume work

## Why This Matters

- Prevents "context anxiety" (agent wrapping up prematurely)
- Clean handoff between sessions
- Never lose work or repeat steps
- Maintains quality across long tasks

## Rules

- Always write to SESSION_STATE.md before checkpoint
- Include exact line numbers for continuation
- Include file paths for all relevant files
- Note any blocked tasks or dependencies
