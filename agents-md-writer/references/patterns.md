## OpenAI Codex — Prompt Structure

Good prompts include four things:

| Element | Purpose | Example |
|---------|---------|---------|
| **Goal** | What to change or build | "Add email validation to the registration form" |
| **Context** | Which files, docs, errors matter | "See src/forms/register.ts and tests in tests/forms/" |
| **Constraints** | Standards and conventions | "Follow existing patterns in src/forms/login.ts" |
| **Done when** | Completion criteria | "All tests pass, no new lint errors" |

### Plan Before Implementing

For complex tasks:
1. Use Plan mode (`/plan` or Shift+Tab) — Codex gathers context, asks clarifying questions
2. Review the plan before coding begins
3. Only then switch to implementation

### Improve Reliability Checklist

After making changes, ask the agent to:
- [ ] Create or update tests
- [ ] Run relevant checks (lint, type, test)
- [ ] Confirm the result matches the goal
- [ ] Review the diff for unintended changes

## Codex Workflow Patterns

### Skills: Package Repeatable Work

- Turn repeated prompts or corrected workflows into **SKILL.md** files
- Use `$skill-creator` to scaffold the first version
- Keep each skill scoped to one job — start with 2-3 concrete use cases
- Good description = what it does + when to use it (include trigger phrases)
- **Skills = method, Automations = schedule** (see below)

### `/init` Command

Scaffolds a starter AGENTS.md by analyzing project structure. Great starting point, but edit to match how your team actually builds, tests, and ships.

### Automations

Schedule Codex to run stable workflows in the background:
- Summarizing recent commits
- Scanning for likely bugs
- Drafting release notes
- Checking CI failures
- Producing standup summaries

**Rule**: if a workflow still needs a lot of steering → make it a skill first. Once predictable → automate.

### Session Management

- **One thread per task** — not per project (prevents bloated context)
- `/compact` when thread gets long (Codex auto-compacts too)
- `/fork` when work truly branches
- `/resume` to continue saved conversations
- Use **subagents** for bounded work (exploration, tests, triage) — keep main agent focused

### MCP for External Context

Connect Codex to tools and systems outside the repo when:
- Context lives outside the repo
- Data changes frequently
- You want Codex to use a tool rather than rely on pasted instructions

### Review Workflow

- `/review` command: PR-style review, uncommitted changes, commit review, custom instructions
- Reference a `code_review.md` file from AGENTS.md for consistent review behavior
- Codex at OpenAI reviews 100% of PRs

### Reasoning Levels

Choose based on task complexity:
- **Low**: faster, well-scoped tasks
- **Medium/High**: complex changes or debugging
- **Extra High**: long, agentic, reasoning-heavy tasks

## GitHub Copilot — Agent Best Practices

### Anti-patterns

- ❌ "You are a helpful coding assistant" — doesn't work
- ❌ Building one general helper instead of specialists
- ❌ Most agents fail because they're too vague

### Best Practices

- Build **specialists**, not general helpers
- Start minimal: name + description + persona (only 3 things needed)
- Pick one simple task (write docs, add tests, fix linting)
- Best agents grow through **iteration**, not upfront planning
- Use Copilot to generate agent files: prompt it to create its own config

### Agent Definition Structure

```markdown
---
name: agent_name
description: One-sentence description of what this agent does
---

You are an expert [role] for this project.

## Your role
- What you specialize in
- What skills you have
- What you do

## Project knowledge
- **Tech Stack:** versions and key dependencies
- **File Structure:** where things live

## Commands you can use
- Build: `command` (what it does)
- Test: `command` (what it does)

## Standards
- Code style rules
- Examples of good output

## Boundaries
- **Always do:** safe operations
- **Ask first:** risky operations
- **Never do:** destructive operations
```

### Six Specialized Agents Worth Building

| Agent | Scope | Key Rule |
|-------|-------|----------|
| **@docs-agent** | Writes documentation, reads code | Only writes to `docs/` |
| **@test-agent** | Writes and runs tests | Never removes failing tests |
| **@lint-agent** | Fixes style and formatting | Never changes logic |
| **@api-agent** | Builds API endpoints | Asks before schema changes |
| **@security-agent** | Scans for vulnerabilities | Read-only, reports findings |
| **@dev-deploy-agent** | Local/dev builds only | Requires approval for staging+ |

### Starter Template for Custom Agents

```markdown
---
name: your-agent-name
description: [One-sentence description]
---

You are an expert [role] for this project.

## Persona
- Specialize in [area]
- Understand [patterns]
- Output: [what you produce]

## Project knowledge
- **Tech Stack:** [versions]
- **File Structure:**
  - `src/` — [what's here]
  - `tests/` — [what's here]

## Tools you can use
- **Build:** `command` (description)
- **Test:** `command` (description)
- **Lint:** `command` (description)

## Standards
Follow these rules for all code:

**Naming:**
- Functions: camelCase
- Classes: PascalCase
- Constants: UPPER_SNAKE_CASE

**Code style example:**
`[insert good vs bad example]`

## Boundaries
- **Always:** [safe operations]
- **Ask first:** [risky operations]
- **Never:** [destructive operations]
```

## Maintenance Lifecycle

Treat AGENTS.md as **code**, not documentation:
- **On PR:** Review AGENTS.md changes when process/structure changes
- **Quarterly:** Audit for accuracy (do commands still work?)
- **Immediately:** Update when commands, dependencies, or structure change
- **Retrospective:** When agent makes the same mistake twice → update AGENTS.md
- **Version:** Include `Last Updated: YYYY-MM-DD` at the bottom
