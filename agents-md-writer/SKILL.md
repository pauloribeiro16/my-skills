---
name: agents-md-writer
description: "Use when creating, updating, or improving AGENTS.md files. Trigger phrases: write agents.md, update agents.md, create onboarding file, improve agent instructions, write CLAUDE.md, project onboarding"
---

# AGENTS.md Writer

Write effective AGENTS.md files that serve as "README for machines" — structured technical guidance for AI coding agents. Based on analysis of 2,500+ repositories and OpenAI/GitHub/Cursor best practices.

## When to Use

- Creating a new AGENTS.md for a project
- Updating an existing AGENTS.md
- Converting CLAUDE.md or .cursorrules to AGENTS.md
- Splitting a large AGENTS.md into hierarchical sub-files
- Reviewing whether an AGENTS.md follows best practices

## Core Principles

### 1. Commands First

Put executable commands early. Agents reference these constantly.

```markdown
## Commands

### File-scoped (preferred — fast feedback)
pytest tests/test_handlers.py
ruff check src/handlers.py

### Full suite (only when explicitly requested)
pytest --cov=src
```

### 2. Code Examples Over Explanations

One real code snippet showing your style beats three paragraphs describing it.

```markdown
## Code Style

```python
# Good — descriptive names, proper error handling
async def fetch_user(id: str) -> User:
    if not id:
        raise ValueError("ID required")
    return await api.get(f"/users/{id}")

# Bad — vague names, no error handling
async def get(x):
    return await api.get("/users/" + x).data
```
```

### 3. Clear Boundaries

Use three-tier boundaries (Always / Ask first / Never):

```markdown
## Boundaries

- **Always:** Run tests before commits, follow naming conventions
- **Ask first:** Database schema changes, adding dependencies
- **Never:** Commit secrets, edit vendor directories, hardcode credentials
```

### 4. Specific Tech Stack

Say "React 18 with TypeScript, Vite, Tailwind" not "React project."

```markdown
## Tech Stack
- **Runtime:** Python 3.12
- **Framework:** FastAPI with Mangum
- **Package Manager:** UV
- **Testing:** pytest with moto
```

## Six Core Areas

The best AGENTS.md files cover these six areas:

| # | Area | What to Include |
|---|------|-----------------|
| 1 | **Commands** | Executable commands with flags, file-scoped first |
| 2 | **Testing** | Test frameworks, how to run, coverage expectations |
| 3 | **Project Structure** | Key directories, what lives where |
| 4 | **Code Style** | Naming, formatting, examples of good/bad |
| 5 | **Git Workflow** | Branch naming, commit style, PR requirements |
| 6 | **Boundaries** | What the agent can/cannot/should-ask-about doing |

## File Structure

### Naming and Location

- **Primary:** `AGENTS.md` at repository root (alongside README.md)
- **Subdirectories:** Additional `AGENTS.md` files in subdirs for monorepos
- **Precedence:** Nearest file in directory tree wins
- **Backward compatibility:** Symlink to CLAUDE.md or .cursorrules if needed

### Size Guidelines

| Scope | Target Size |
|-------|-------------|
| Root AGENTS.md | <150 lines |
| Subdirectory AGENTS.md | <100 lines |
| If larger | Split into nested files or `@./path` references |

## Security Rules

**Never include in AGENTS.md:**
- API keys, tokens, passwords
- Database connection strings with passwords
- AWS access keys or secret keys
- Private encryption keys
- Production IP addresses or internal URLs

**Do include:**
- Where secrets live ("AWS Secrets Manager", ".env (gitignored)")
- How to access them ("use IAM roles", "retrieve from secrets manager")
- Environment variable names (structure only, not values)

## Hierarchical Organization

For monorepos or large projects:

```
project/
├── AGENTS.md              # Organization-wide standards
├── backend/
│   └── AGENTS.md         # Python/FastAPI specific
├── frontend/
│   └── AGENTS.md         # React/TypeScript specific
└── infrastructure/
    └── AGENTS.md         # Terraform specific
```

Each file focuses on its domain. Root covers general practices; subdirs provide technology-specific details.

## Workflow

1. **Analyze the codebase**
   - Detect build system, test framework, package manager
   - Identify tech stack and versions
   - Map project structure

2. **Write the core AGENTS.md**
   - Start with commands (setup, test, build)
   - Add project structure
   - Add code style with examples
   - Add boundaries
   - Keep under 150 lines

3. **Add subdirectory files** (if needed)
   - Split when root file exceeds 150 lines
   - Each sub-file focuses on one domain

4. **Validate**
   - Can an agent set up the environment from this file?
   - Can it run tests? Build? Deploy?
   - Are all commands copy-pasteable?

## Templates

- **Minimal:** `references/template-minimal.md` — for simple projects
- **Comprehensive:** `references/template-comprehensive.md` — for complex projects
- **Best practices:** `references/best-practices.md` — detailed guidance from 2500+ repos

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Too verbose (>200 lines) | Split into subdirs, link instead of duplicating |
| Vague commands ("run tests") | Use exact commands with flags (`pytest tests/unit/`) |
| No boundaries | Add Always/Ask/Never section |
| Including secrets | Reference secret location, never the value |
| Outdated info | Review in PRs when processes change |
| Forcing full builds | Provide file-scoped commands first |

## Quick Reference

```
AGENTS.md = Commands + Structure + Style + Testing + Git + Boundaries
Keep it <150 lines. Be specific. Show examples. Never include secrets.
```