---
name: skill-creator
description: "Use when creating a new skill, improving skill descriptions, or organizing skill content. Trigger phrases: create a skill, add a skill to plugin, write a new skill, improve skill description, organize skill content."
---

# Skill Creator

Create high-quality skills that load reliably and provide deep knowledge on demand. Based on progressive disclosure principles.

## When to Use

- Creating a new skill for your project or globally
- Improving an existing skill's description or structure
- Organizing skill content across multiple files
- Writing trigger phrases that reliably load the right skill

## Skill Structure

Every skill lives in a directory with a `SKILL.md` file:

```
~/.config/opencode/skills/<name>/
└── SKILL.md
```

Or for project-local skills:

```
.opencode/skills/<name>/
└── SKILL.md
```

## YAML Frontmatter

`SKILL.md` must start with YAML frontmatter. Only these fields are recognized:

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Skill name (1-64 chars, lowercase alphanumeric + hyphens) |
| `description` | Yes | 1-1024 chars. Specific enough for the agent to choose correctly |
| `license` | No | License identifier |
| `compatibility` | No | Compatibility tag |
| `metadata` | No | String-to-string map for additional data |

### Name Validation Rules

- 1-64 characters
- Lowercase alphanumeric with single hyphen separators
- Cannot start or end with `-`
- Cannot contain consecutive `--`
- Must match the directory name

### Example Frontmatter

```yaml
---
name: git-release
description: Create consistent releases and changelogs
license: MIT
compatibility: opencode
metadata:
  audience: maintainers
  workflow: github
---
```

## Progressive Disclosure

Skills should use three-level disclosure:

### Level 1: Metadata (Always Loaded)

Concise `name` + `description` with strong trigger phrases. The agent sees this before deciding whether to load the skill.

**Rule**: Keep descriptions under 1024 characters but specific enough to differentiate from similar skills.

### Level 2: Core SKILL.md (On Demand)

When the skill is loaded, provide essential reference content (~500-1500 words). Structure it with:

- **When to use** section with specific trigger phrases
- **What it covers** with numbered capabilities
- **Resources** section listing references and examples
- **Use when** closing statement

### Level 3: References and Examples (As Needed)

For detailed guides, patterns, and working code, organize in subdirectories:

```
skill-name/
├── SKILL.md
├── references/
│   ├── patterns.md
│   └── migration.md
├── examples/
│   └── basic-usage.sh
└── scripts/
    └── validate.sh
```

## Writing Strong Trigger Descriptions

Trigger descriptions are the agent's primary way to decide whether to load a skill. Write descriptions that:

### Do

- Include specific phrases the agent will actually say
- Mention the exact operation (not just the domain)
- Reference the tool or API being used
- Include edge cases or variations

### Don't

- Use generic descriptions like "code quality" or "helpful tips"
- List every possible synonym
- Make it sound like documentation rather than a skill

### Examples

| Weak | Strong |
|------|--------|
| "Git operations" | "Create commits, push branches, and manage git history. Trigger phrases: commit changes, push to remote, undo last commit, create branch" |
| "Testing" | "Write and run tests for Python and JavaScript. Trigger phrases: write tests for, run test suite, add test coverage, mock a function" |
| "Security" | "Find security vulnerabilities in code. Trigger phrases: scan for SQL injection, check for XSS, detect secrets in code" |

## Writing Style

### Voice and Tone

- Use **third person** for descriptions: "This skill should be used when..."
- Use **imperative or infinitive form** for instructions: "Add the field", "Configure the hook"
- Keep sentences concise
- Prefer active voice

### Structure

1. **Header** with skill name and one-line purpose
2. **When to Use** with specific trigger phrases
3. **What It Covers** with numbered capabilities
4. **Resources** section (optional)
5. **Use When** closing statement

## Skill Content Organization

### SKILL.md Template

```markdown
---
name: <skill-name>
description: "<trigger phrases> and <operations>. Trigger phrases: <specific phrases>"
---

# <Skill Name>

<Brief purpose statement in one sentence>

## When to Use

<Specific trigger phrases that reliably load this skill>

## What It Covers

1. <first capability>
2. <second capability>
3. <third capability>

## Resources

- Core SKILL.md (this file)
- references/<reference-name>.md — <description>
- examples/<example-name>.<ext> — <description>

## Use When

<Closing statement with specific use cases>
```

## Directory Naming

Directory name must match `name` in frontmatter exactly (lowercase, hyphens).

```
~/.config/opencode/skills/skill-creator/SKILL.md  ✅
~/.config/opencode/skills/skillCreator/SKILL.md    ❌
```

## Skill Discovery

opencode searches these locations:

| Scope | Path |
|-------|------|
| Global | `~/.config/opencode/skills/<name>/SKILL.md` |
| Global (Claude-compatible) | `~/.claude/skills/<name>/SKILL.md` |
| Global (Agents-compatible) | `~/.agents/skills/<name>/SKILL.md` |
| Project | `.opencode/skills/<name>/SKILL.md` |
| Project (Claude-compatible) | `.claude/skills/<name>/SKILL.md` |

## Validation Checklist

Before finalizing a skill, verify:

- [ ] `name` matches directory name exactly
- [ ] `name` is 1-64 chars, lowercase alphanumeric + hyphens only
- [ ] `description` is 1-1024 characters
- [ ] `description` contains specific trigger phrases
- [ ] SKILL.md starts with valid YAML frontmatter
- [ ] Content uses progressive disclosure appropriately
- [ ] Content is written in third person / imperative style
- [ ] No project-specific content in global skills

## Workflow: Create a New Skill

1. **Identify the skill's purpose**
   - What trigger phrases will load it?
   - What specific operations does it cover?
   - Is it project-specific or reusable?

2. **Choose the scope**
   - Global: `~/.config/opencode/skills/<name>/`
   - Project: `.opencode/skills/<name>/`

3. **Write the frontmatter**
   - Craft a `description` with strong trigger phrases
   - Validate name follows naming rules

4. **Write the core SKILL.md**
   - Start with one-line purpose statement
   - Add "When to Use" with trigger phrases
   - List capabilities with numbers
   - Close with "Use When" statement

5. **Add references and examples** (optional)
   - Create `references/` for detailed docs
   - Create `examples/` for working code

6. **Test the skill**
   - Ask a question that should trigger the skill
   - Verify the skill loads and provides useful guidance