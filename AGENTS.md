# My Skills — AGENTS.md

## Repo Scope

Collection of skills for OpenCode and Claude. Adapted from the official
Anthropic repository (`anthropics/skills`) with custom skills added. Each
directory is an independent skill with a `SKILL.md`.

## Directory Structure

### Documents & Office
| Skill | Description |
|-------|-------------|
| `docx` | Create/edit Word (.docx) |
| `xlsx` | Manipulate Excel (.xlsx) |
| `pptx` | Create PowerPoint presentations |
| `pdf` | Manipulate PDFs |
| `doc-coauthoring` | Document co-authoring |

### Design & Creative
| Skill | Description |
|-------|-------------|
| `algorithmic-art` | Algorithmic art with p5.js |
| `frontend-design` | Web interface design |
| `theme-factory` | Custom themes (colors, fonts) |
| `slack-gif-creator` | GIFs optimized for Slack |
| `brand-guidelines` | Brand guidelines |

### Development & Technical
| Skill | Description |
|-------|-------------|
| `mcp-builder` | Build MCP servers |
| `web-artifacts-builder` | Web artifacts HTML/CSS/JS |
| `webapp-testing` | Test web apps with Playwright |
| `skill-creator` | Create/validate skills |
| `codebase-architecture` | Codebase architecture analysis |
| `python-best-practices` | Modern Python best practices |
| `project-conventions` | AEGIS-KG project conventions (naming, structure, errors) |

### OpenCode Skills
| Skill | Description |
|-------|-------------|
| `feature-dev` | 7-phase feature development workflow |
| `code-review` | Code review with multi-agent scoring |
| `commit-workflow` | Git automation (commit, push, PR) |
| `sprint-contract` | Contracts with validation tiers |
| `agents-md-writer` | Write AGENTS.md files |
| `context-checkpoint` | Checkpoint for long sessions |
| `etl-runner` | ETL with tenant isolation |
| `eval-runner` | Progressive task evaluation |
| `service-verify` | Endpoint/config verification |
| `security-hooks` | Gitleaks, detect-secrets, CI |
| `neo4j-verify` | Verify Neo4j ports (7688/7475) before/after work |

### LLM Stack
| Skill | Description |
|-------|-------------|
| `langchain` | LangChain chains, RAG, LCEL |
| `langgraph` | Stateful agent workflows |
| `langfuse` | Observability, tracing, monitoring |
| `llm-observability-stack` | Full LLM + observability stack |

### Enterprise & Communication
| Skill | Description |
|-------|-------------|
| `internal-comms` | Internal communications (newsletters, announcements) |

## Skill Conventions

- Each skill is a directory: `skill-name/SKILL.md`
- YAML frontmatter required: `name`, `description`
- Names: lowercase alphanumeric + hyphens (no leading/trailing `-`)
- Progressive disclosure: concise SKILL.md, `references/` for details
- Descriptions with specific trigger phrases ("pushy" style)
- Optional: `scripts/`, `examples/`, `templates/`, `assets/`

## Installation

```bash
# OpenCode global
cp -r <skill-dir> ~/.config/opencode/skills/

# OpenCode local (project)
cp -r <skill-dir> .opencode/skills/

# Claude
cp -r <skill-dir> ~/.claude/skills/
```

## Creating a New Skill

1. Create `skill-name/` directory
2. Write `SKILL.md` with YAML frontmatter + content
3. Add `references/` if SKILL.md exceeds ~300 lines
4. Update the table in `README.md`
5. Commit: `feat: add skill-name skill`

## Commands

- `git add -A && git commit -m "feat: <msg>" && git push`
- Commit convention: conventional commits (feat:, refactor:, docs:, chore:)

## Boundaries

- **Always**: Create/edit skills in this repo, update README.md
- **Ask first**: Delete skills, change existing structure, rename directories
- **Never**: Include secrets/tokens, malicious skills, break YAML frontmatter
