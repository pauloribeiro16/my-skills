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

1. **All AGENTS.md files must be ≤150 lines.** Root and sub-files share the same limit. If larger → condense or split.
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

## Evaluation Guidelines

Before making changes to an AGENTS.md file, evaluate its current state:

1. **Structure Type**: Determine if it's hierarchical or simple
2. **Consistency Check**: Identify patterns to maintain
3. **Change Impact**: Assess what needs to be preserved

### Hierarchical vs Simple

| Aspect | Hierarchical | Simple |
|--------|--------------|--------|
| Size | ≤150 lines per file | ≤150 lines |
| Scope | Multiple domains | Single domain |
| Organization | Split into sub-AGENTS.md | Single file |
| Use Case | Complex projects | Simple projects |

### Evaluation Process

1. Read the entire AGENTS.md file
2. Check line count and structure
3. Identify existing patterns and conventions
4. Determine if changes should maintain hierarchy or simplify
5. Note sections that should be preserved or updated

## Maintaining Hierarchical Consistency

When working with hierarchical AGENTS.md structures:

1. **Root File**: Keep general rules, commands, and boundaries
2. **Sub-files**: Maintain domain-specific content
3. **Links**: Use cross-references between files
4. **Avoid Duplication**: Ensure information isn't repeated across files
5. **Size Limits**: All files ≤150 lines (root and sub-files share the same limit)

### Transition Guidelines

When converting between hierarchical and simple structures:

1. **Hierarchical to Simple**:
   - Consolidate content from sub-files
   - Remove redundant information
   - Maintain all critical sections

2. **Simple to Hierarchical**:
   - Identify logical domains for splitting
   - Create appropriate sub-files
   - Maintain root file with general rules

## Writing Style for AGENTS.md

- **Be specific:** "React 18 with TypeScript, Vite, Tailwind" not "React project"
- **Show examples:** Good code vs bad code with concrete snippets
- **Put commands early:** Setup and test commands before explanations
- **Think like onboarding:** What would a new teammate need for their first PR?
- **Iterate:** Update when the agent makes the same mistake twice

## Updated Workflow

```
1. EVALUATE → Assess current AGENTS.md structure and content
2. ANALYZE → Detect build system, test framework, package manager, tech stack
3. PLAN → Determine changes needed while preserving existing patterns
4. WRITE → Commands first, then structure, style, boundaries
5. CHECK SIZE → If >150 lines → condense or split
6. VALIDATE → Can an agent setup, test, build, deploy from this file alone?
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Too verbose (>150 lines) | Condense or split into subdirectory files |
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
AGENTS.md = Commands + Structure + Style + Testing + Git + Boundaries. All files ≤150 lines. Commands first. Show examples. Never secrets. Split when >150 lines or monorepo. Nearest file wins.
```