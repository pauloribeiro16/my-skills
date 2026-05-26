---
name: agents-md-writer
description: "Use when creating, updating, or improving AGENTS.md files. Trigger phrases: write agents.md, update agents.md, create onboarding file, improve agent instructions, write CLAUDE.md, project onboarding"
---

# AGENTS.md Writer

Write effective AGENTS.md files: "README for machines" with structured technical guidance for AI coding agents. Based on analysis of 2,500+ repositories, OpenAI Codex, and GitHub Copilot best practices.

## When to Use

- Creating a new AGENTS.md for a project
- Updating or reviewing an existing AGENTS.md
- Converting CLAUDE.md / .cursorrules / copilot-instructions.md to AGENTS.md
- Splitting a large AGENTS.md into hierarchical sub-files

## Hard Rules

1. **Root AGENTS.md must be <150 lines.** If larger → split into subdirectory files.
2. **Six core areas** every AGENTS.md must cover: Commands, Testing, Structure, Style, Git, Boundaries.
3. **Never include secrets.** Reference where they live, not the values.
4. **Commands must be copy-pasteable.** Exact commands with flags, not "run the tests."
5. **File-scoped commands first.** Full suite only as fallback.
6. **Code examples over explanations.** One snippet beats three paragraphs.
7. **Skills activation**: Document how skills are loaded.
8. **Complements README.md**: AGENTS.md is for machines; don't duplicate human-oriented content.

## Six Core Areas

| Priority | Area | What to Include |
|----------|------|-----------------|
| 1 | **Commands** | Setup, file-scoped tests/lint, full suite. Exact with flags. |
| 2 | **Testing** | Framework, how to run single file + full suite, coverage target. |
| 3 | **Project Structure** | Key directories with one-line descriptions. |
| 4 | **Code Style** | Naming, formatting, good/bad examples. |
| 5 | **Git Workflow** | Branch naming, commit format, PR requirements. |
| 6 | **Boundaries** | Three tiers: Always / Ask first / Never. |

## Skills Section in AGENTS.md

Every AGENTS.md should include a skills section explaining how skills are activated:

```markdown
## Skills (Activate on Demand)

Skills are loaded via the `skill` tool. When a task matches a skill's
description, call `skill({ name: "skill-name" })` to load its instructions.

| Skill | When |
|-------|------|
| **skill-name** | Trigger description |
```

Separate global skills from project-local skills when both exist.

## When to Suggest Hierarchical Splitting

Suggest splitting into subdirectory AGENTS.md files when **any** of these are true:

| Trigger | Action |
|---------|--------|
| Root AGENTS.md exceeds 150 lines | Split largest section into subdirectory file |
| Monorepo with distinct tech stacks | One AGENTS.md per component (backend/, frontend/, infra/) |
| Single domain exceeds 80 lines | Extract to subdirectory AGENTS.md |
| 3+ distinct environments (dev/staging/prod) | Separate infrastructure/AGENTS.md |
| Root has >6 sections | Move domain-specific sections down |

### Hierarchical Pattern

OpenAI's main repository uses **88 AGENTS.md files** across subcomponents.

```
project/
├── AGENTS.md              # Org-wide: commands, style, boundaries (<150 lines)
├── backend/
│   └── AGENTS.md         # Python/FastAPI specific (<100 lines)
├── frontend/
│   └── AGENTS.md         # React/TypeScript specific (<100 lines)
└── infrastructure/
    └── AGENTS.md         # Terraform/AWS specific (<100 lines)
```

Rules:
- **Nearest file wins.** Subdirectory AGENTS.md overrides root for that path.
- **Root stays general.** Commands, style, boundaries, git workflow.
- **Sub-files are domain-specific.** Tech stack details, patterns, examples.
- **No duplication.** If root has it, sub-file doesn't repeat it.
- **Link, don't copy.** Use `See docs/api.md for API reference` instead of pasting.

## Three-Tier Boundaries

Every AGENTS.md must include:

```markdown
## Boundaries

- **Always:** [safe operations the agent does without asking]
- **Ask first:** [risky operations requiring user approval]
- **Never:** [destructive operations the agent must never do]
```

Common "Never" items:
- Commit secrets, API keys, or credentials
- Edit vendor/generated directories
- Hardcode URLs, regions, or table names
- Delete tests because they fail
- Modify production configs without approval

## Writing Style for AGENTS.md

- **Be specific:** "React 18 with TypeScript, Vite, Tailwind" not "React project"
- **Show examples:** Good code vs bad code with concrete snippets
- **Put commands early:** Setup and test commands before explanations
- **Think like onboarding:** What would a new teammate need for their first PR?
- **Iterate:** Update when the agent makes the same mistake twice

## Workflow

```
1. ANALYZE    → Detect build system, test framework, package manager, tech stack
2. WRITE      → Commands first, then structure, style, boundaries
3. CHECK SIZE → If >150 lines → suggest hierarchical split (see triggers above)
4. VALIDATE   → Can an agent setup, test, build, deploy from this file alone?
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Too verbose (>150 lines) | Split into subdirectory files |
| Vague commands | Use exact commands: `pytest tests/unit/` not "run tests" |
| No boundaries | Add Always/Ask/Never section |
| Including secrets | Reference location, never the value |
| Forcing full builds | Provide file-scoped commands first |
| No code examples | Add good/bad snippets |
| Outdated info | Review in PRs, treat as living code |

## References

- `references/ecosystem.md` — Adoption, tool compatibility, parsing differences (Codex, Copilot, Cursor, Claude)
- `references/patterns.md` — Codex workflow patterns, GitHub agent best practices, prompt structure, maintenance
- `references/security.md` — Security deep dive, scanning tools, CI/CD gates, deployment validation
- `references/template-minimal.md` — Simple project template (~85 lines)
- `references/template-comprehensive.md` — Complex project template with tech patterns (~400 lines)

## Quick Reference

```
AGENTS.md = Commands + Structure + Style + Testing + Git + Boundaries. Root <150 lines. Commands first. Show examples. Never secrets. Split when >150 lines or monorepo. Nearest file wins.
```