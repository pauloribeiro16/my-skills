# SESSION_STATE — YYYY-MM-DD

**Last Updated:** YYYY-MM-DD HH:MM

---

## Completed

- [ ] Task A (file:line)

## In Progress

- [ ] Task B — blocked by X

## Next Steps

1. Continue Task B
2. Run code-reviewer on Task A
3. Update CONTRACT.md

## Exact Continuation Point

```
File: path/to/file.py
Line: line number
Next action: what to do next
```

## Context Summary

- **Working on:** [description]
- **Key files:** [list]
- **Project:** [project_name]
- **LLM provider:** [provider_name]

## Dependencies

- [ ] Task C depends on external API
- [ ] Task D blocked by user input

## Active Phased Goal

- **Goal Decomposition:** [path/to/GOAL_DECOMPOSITION.md] — [omit if not applicable]
- **Current Phase:** [N of M] — [omit if not applicable]
- **Phase Status:** [PENDING / IN_PROGRESS / BLOCKED / COMPLETED] — [omit if not applicable]
- **Next Phase:** [N+1] — [description] — [omit if not applicable]
- **Blocked Reason:** [if applicable]

## Phase History

| Phase | Contract | Result | Score | Date |
|-------|----------|--------|-------|------|
| 1 | CONTRACT-phase-1.md | PASS/FAIL | [N%] | YYYY-MM-DD |
| 2 | CONTRACT-phase-2.md | PASS/FAIL | [N%] | YYYY-MM-DD |

## Git State

- **Current Branch:** [branch name]
- **Last Commit:** [hash] — [message]
- **Commits in Phase:** [N]
- **Uncommitted Changes:** [none/pending]
- **Merge Status:** [pending/completed/blocked]

### Commit History

| Hash | Message | Phase | Date |
|------|---------|-------|------|
| [hash] | feat: ... — phase 1/3 | 1 | YYYY-MM-DD |
| [hash] | feat: ... — phase 2/3 | 2 | YYYY-MM-DD |

## Handoff Notes

- Don't restart from scratch — read SESSION_STATE.md first
- Check here for blocked tasks
- code-reviewer should verify before continuing
