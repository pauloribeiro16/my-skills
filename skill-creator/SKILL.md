---
name: skill-creator
description: "Use when creating a new skill, improving skill descriptions, or organizing skill content. Trigger phrases: create a skill, add a skill to plugin, write a new skill, improve skill description, organize skill content."
---

Creates, edits, and iterates on local ZCode skills. Aligned with the workspace AGENTS.md §10 convention: frontmatter uniforme, H2 esqueleto canónico, estilo imperativo + "why".

## When to Use

- A new skill is needed for a repeated workflow.
- An existing skill keeps triggering on the wrong prompts (description too broad or too narrow).
- A skill is too long and needs splitting into SKILL.md + references/.
- Reviewing or auditing existing skills against the AGENTS.md §10 convention.

## When NOT to Use

- Documentation files in human prose (READMEs, ADRs) — those go through agents-md-writer if they need to be machine-readable too.
- Updating plugin manifests (plugin.json, marketplace configs) — separate concern.
- Generating throwaway scripts — write them to tmp/, not as a skill.

## Hard Rules

1. **Follow the workspace AGENTS.md §10 convention** if one is defined. The local AGENTS.md §10 is the contract; deviations must be asked, not assumed. The convention is: frontmatter name (kebab-case, matches folder) + description (in double quotes) + license when LICENSE.txt exists; required H2 sections When to Use, When NOT to Use, Hard Rules (≤8 numbered, imperative with why), Examples (≥1 runnable code block); style imperative + why (avoid all-caps NEVER/MUST/CRITICAL).
2. **Description is the trigger** — the model decides whether to load a skill by matching the description. Front-load the trigger wording in the first ~250 characters, because the description is truncated there.
3. **Skills are progressive disclosure** — SKILL.md is the body the model reads first (target ≤150 lines, never above 500). Move detail to references/<topic>.md files and have SKILL.md tell the model when to read them.
4. **Prefer references over long bodies** — if the body is getting past ~200 lines, split. Each reference is a self-contained file the model can read on demand.
5. **Run the test prompts after writing** — a skill is not done until you have tried it on 2-3 realistic user prompts. "Looks right" is not verification.
6. **Examples beat rules** — a literal example of the format or output is more useful than three paragraphs of explanation. Include ≥1 in the Examples section.
7. **Frontmatter name must match the directory name** — if they differ, the skill is shadowed by another of the same name in the discovery order. The model sees the first one, not yours.

## Examples

Minimal skill, following the §10 convention:

```markdown
---
name: my-skill
description: "Use when X. Trigger phrases: x, y, z."
---

## When to Use

- Bullet list of trigger contexts.

## When NOT to Use

- What this skill is **not** for.

## Hard Rules

1. **First rule** — imperative + why.
2. **Second rule** — imperative + why.

## Examples

\`\`\`bash
# A runnable example the model can copy.
\`\`\`
```

Skill with progressive disclosure (body + references):

```text
my-skill/
├── SKILL.md              # ≤150 lines — essence + routing table
└── references/
    ├── detail-a.md       # 50-100 lines
    └── detail-b.md       # 50-100 lines
```

```markdown
## References

| If you are… | Read… |
|---|---|
| Doing X | references/detail-a.md |
| Doing Y | references/detail-b.md |
```

## Validation Checklist

After writing a draft, before committing:

- [ ] Frontmatter has name (matches folder) and description (in double quotes, ≤1024 chars, trigger front-loaded).
- [ ] When to Use lists trigger contexts.
- [ ] When NOT to Use is present (or omitted deliberately with a reason).
- [ ] Hard Rules is numbered, ≤8 rules, imperative + why.
- [ ] Examples has ≥1 runnable code block.
- [ ] SKILL.md is ≤150 lines (or split into references/ if longer).
- [ ] Tested on 2-3 realistic prompts; behavior matches the description.
