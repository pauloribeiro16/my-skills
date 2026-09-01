# My Skills

A collection of skills for OpenCode and Claude, adapted from Anthropic's official repository (`anthropics/skills`).

> **License:** MIT — see [LICENSE](./LICENSE) for the full text.

## Table of Contents

- [Structure](#structure)
- [Documents](#documents)
- [Design & Creative](#design--creative)
- [Development & Technical](#development--technical)
- [Data, AI & Observability](#data-ai--observability)
- [Security](#security)
- [Enterprise & Communication](#enterprise--communication)
- [OpenCode Skills](#opencode-skills)
- [Web Debugging](#web-debugging)
- [How to Use](#how-to-use)
- [Conventions](#conventions)
- [License](#license)
- [Credits](#credits)

## Structure

This repository contains skills organised by category for different use cases.

All skills follow the convention defined in [`AGENTS.md`](./AGENTS.md) §10 — `frontmatter` with `description`, an H2 skeleton, and a `When to Use` section.

---

## Documents

Skills for Microsoft Office and PDF document manipulation.

| Skill | Description |
|-------|-------------|
| **`docx`** | Create and edit Word documents (.docx) — formatting, tables, styles, headers/footers |
| **`xlsx`** | Manipulate Excel spreadsheets (.xlsx) — formulas, charts, pivot tables, conditional formatting |
| **`pdf`** | Create and edit PDFs — text extraction, annotations, forms, merging |
| **`pptx`** | Create PowerPoint presentations (.pptx) — slides, animations, charts, layouts |
| **`doc-coauthoring`** | Document co-authoring with revision tracking and comments |

---

## Design & Creative

Skills for visual content creation and design.

| Skill | Description |
|-------|-------------|
| **`algorithmic-art`** | Algorithmic art — patterns, fractals, generative visualisations |
| **`frontend-design`** | Web interface design — layouts, components, styles |
| **`theme-factory`** | Create custom themes — colour palettes, typography, components |
| **`slack-gif-creator`** | Create GIFs optimised for Slack and other platforms |
| **`brand-guidelines`** | Brand guidelines — logos, colours, typography, brand voice |

---

## Development & Technical

Skills for programming and developer tooling.

| Skill | Description |
|-------|-------------|
| **`mcp-builder`** | Build MCP (Model Context Protocol) servers |
| **`web-artifacts-builder`** | Build web artifacts — interactive HTML/CSS/JS components |
| **`webapp-testing`** | Test web applications — UI, API, performance tests |
| **`skill-creator`** | Create new skills — structure, validation, best practices |
| **`codebase-architecture`** | Codebase architecture analysis and improvement — deepening, modularisation, seams |
| **`python-best-practices`** | Modern Python best practices — PEP 8, type hints, testing, tooling |
| **`react-naming`** | Naming and folder structure reference for React/TypeScript projects (Max Schwarzmüller course) |

---

## Data, AI & Observability

Skills for LLM, data pipelines, and observability.

| Skill | Description |
|-------|-------------|
| **`langchain`** | Build applications with LangChain |
| **`langgraph`** | Build stateful, multi-actor applications with LangGraph |
| **`langfuse`** | LLM observability and evaluation with Langfuse |
| **`llm-observability-stack`** | LLM observability stack — tracing, evaluation, monitoring |
| **`hpc-deucalion`** | Operate AEGIS-KG on Deucalion HPC — SLURM, sbatch, srun, compute nodes, Lmod modules, GPU partitions |
| **`neo4j-verify`** | Verify Neo4j configurations (ports 7688/7475) before and after work |
| **`etl-runner`** | Run ETL scripts to load data into Neo4j with correct port and sequential phases |
| **`eval-runner`** | Run evaluation tasks with progressive scaling (1 → 3 → max 5 trials) and timeout handling |
| **`service-verify`** | Verify service endpoint/port configuration and detect hardcoded connection strings |

---

## Security

Skills for security tooling and CI workflows.

| Skill | Description |
|-------|-------------|
| **`security-hooks`** | Setup security hooks and CI workflows — gitleaks, detect-secrets, GitHub Actions scanning, baselines |

---

## Enterprise & Communication

Skills for enterprise environments and communication.

| Skill | Description |
|-------|-------------|
| **`internal-comms`** | Internal communications — newsletters, announcements, team updates |

---

## OpenCode Skills

Original skills for OpenCode.

| Skill | Description |
|-------|-------------|
| **`feature-dev`** | 7-phase workflow for feature development (Discovery, Exploration, Clarification, Design, Implementation, Review, Summary) |
| **`code-review`** | Automated code review with confidence scoring (0-100) and multiple agents |
| **`commit-workflow`** | Git automation — commits, push, PR creation, branch cleanup |
| **`sprint-contract`** | Implementation contracts with validation tiers (T1-T4), pass@k trials, and phased decomposition |
| **`agents-md-writer`** | Write AGENTS.md and CLAUDE.md files for projects |
| **`context-checkpoint`** | Context checkpoint for long sessions (>70% context window) — structured handoff to next session |
| **`project-conventions`** | AEGIS-KG project conventions — naming, file structure, function patterns, error handling |

---

## Web Debugging

Skills for diagnosing and fixing browser issues.

| Skill | Description |
|-------|-------------|
| **`web-debug`** | Debug broken browser behaviour — page errors, JS failures, layout issues, unresponsive clicks. Routes by reproducibility |

---

## How to Use

### OpenCode

Place skills in `~/.config/opencode/skills/`:

```bash
cp -r skills/* ~/.config/opencode/skills/
```

### Claude (Desktop)

Place skills in `~/.claude/skills/`:

```bash
cp -r skills/* ~/.claude/skills/
```

---

## Conventions

All skills in this repository follow the structure defined in [`AGENTS.md`](./AGENTS.md) §10:

- YAML frontmatter with `name` and `description` fields
- H2 skeleton (e.g. `# When to Use`, `# Workflow`, `# Outputs`)
- Progressive disclosure — detailed content moved to `references/`
- Trigger phrases in the description to enable automatic activation

---

## License

This repository is licensed under the **MIT License**. See the [LICENSE](./LICENSE) file for the full text.

> **Note on third-party content:** Original Anthropic skills are released under their respective licences (see each skill individually). OpenCode-original skills are MIT-licensed. When redistributing individual skills, retain their original notices where applicable.

```
MIT License

Copyright (c) 2026 Paulo Ribeiro

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## Credits

- **Anthropic** — for the original [`anthropics/skills`](https://github.com/anthropics/skills) repository
- **OpenCode** — for the skills framework
