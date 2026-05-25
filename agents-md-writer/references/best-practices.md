# AGENTS.md Best Practices

Synthesized from OpenAI Codex docs, GitHub Copilot analysis (2,500+ repos), and community best practices.

## Key Insights from 2,500+ Repositories

### What Works

1. **Commands first** — Put relevant executable commands in an early section
2. **Code examples over explanations** — One real snippet beats three paragraphs
3. **Clear boundaries** — Tell AI what it should never touch
4. **Specific stack** — "React 18 with TypeScript, Vite" not "React project"
5. **Six core areas** — Commands, testing, structure, style, git, boundaries

### What Fails

1. **Vague persona** — "You are a helpful coding assistant" doesn't work
2. **No boundaries** — Agents touch files they shouldn't
3. **Full builds only** — Forces slow iteration, wastes time
4. **Outdated info** — Worse than no instructions
5. **Too long** — >200 lines buries important information

## OpenAI Codex Best Practices

### Prompt Structure

Good prompts include four things:
- **Goal:** What are you trying to change or build?
- **Context:** Which files, folders, docs, or errors matter?
- **Constraints:** What standards or conventions should Codex follow?
- **Done when:** What should be true before the task is complete?

### AGENTS.md as "README for Machines"

- Loads into context automatically
- Best place to encode how your team wants Codex to work
- Covers repo layout, build/test commands, conventions, constraints
- Short and accurate > long and vague

### Plan Before Implementing

For complex tasks:
- Use Plan mode (`/plan` or Shift+Tab)
- Let Codex gather context and ask clarifying questions
- Review the plan before coding

### Improve Reliability

Don't stop at making changes. Ask the agent to:
- Create/update tests
- Run relevant checks
- Confirm the result
- Review the diff

## GitHub Copilot Analysis

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

### Six Agents Worth Building

1. **@docs-agent** — Writes documentation, reads code, writes to docs/
2. **@test-agent** — Writes tests, runs tests, never removes failing tests
3. **@lint-agent** — Fixes style/formatting, never changes logic
4. **@api-agent** — Builds API endpoints, asks before schema changes
5. **@security-agent** — Scans for vulnerabilities, reviews for security
6. **@dev-deploy-agent** — Local/dev builds only, requires approval

### Starter Template

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
```typescript
// Good
def fetch_user(id: str) -> User:
    if not id:
        raise ValueError("ID required")
    return await api.get(f"/users/{id}")
```

## Boundaries
- **Always:** [safe operations]
- **Ask first:** [risky operations]
- **Never:** [destructive operations]
```

## Context Window Management

Different tools have varying limits:
- OpenAI Codex: 128k-192k tokens
- Claude Opus 4: 200k tokens
- GitHub Copilot: varies by model
- Gemini: 1M tokens

Strategies:
- Keep AGENTS.md <150 lines (root)
- Use nested files for subdirs
- Link instead of duplicating
- Prioritize commands and examples

## Hierarchical Configuration

OpenAI's main repository uses 88 AGENTS.md files across subcomponents.

Pattern:
```
project/
├── AGENTS.md              # Org-wide standards
├── backend/
│   └── AGENTS.md         # Domain-specific
├── frontend/
│   └── AGENTS.md         # Domain-specific
└── docs/
    └── AGENTS.md         # Domain-specific
```

Nearest file takes precedence.

## Security First Principles

- Never include actual secrets in AGENTS.md
- Reference secret storage systems, never secrets themselves
- Run secret scanning before committing
- Enable GitHub push protection
- Assume AGENTS.md could be used to train models

## Maintenance

- Review in pull requests when processes change
- Treat as code, not static documentation
- Audit quarterly for accuracy
- Update immediately when commands or structure change
- When agent makes same mistake twice → retrospective → update AGENTS.md