## AGENTS.md Ecosystem

### Adoption

- 20,000+ repositories adopted AGENTS.md
- Formalized August 2025 through collaboration between OpenAI, Google, Cursor, Factory, and Sourcegraph
- GitHub Copilot added native support in August 2025
- Other tools: Aider, Gemini CLI, Windsurf, Zed, RooCode, Android Studio Gemini

### File Naming & Location

- **AGENTS.md** (plural) at repository root alongside README.md
- Nearest file in directory tree takes precedence
- OpenAI's main repository uses **88 AGENTS.md files** across subcomponents

### Backward Compatibility

Create symlinks for legacy tool support:

```bash
ln -s AGENTS.md CLAUDE.md
ln -s AGENTS.md .github/copilot-instructions.md
ln -s AGENTS.md .cursorrules
```

### How Tools Parse AGENTS.md

| Tool | Parsing Method | Notes |
|------|---------------|-------|
| **Codex** | Auto-searches files whose scope includes modified files; cascading configuration | `/init` command scaffolds starter AGENTS.md |
| **Copilot** | Server-side processing with YAML frontmatter | Uses `applyTo: "src/**/*.py"` glob patterns for path-specific instructions |
| **Cursor** | `.cursor/rules/` directory with `.mdc` files | 4 rule types: Always, Auto Attached, Agent Requested, Manual |
| **Claude** | Primary: `CLAUDE.md`; reads AGENTS.md via symlinks | Hierarchical files; nearest wins; Skills system with `SKILL.md` files |
| **Aider** | Via `.aider.conf.yml` | `read: AGENTS.md` |
| **Gemini CLI** | Via `.gemini/settings.json` | `{"contextFileName": "AGENTS.md"}` |

### File Imports

Some tools support modular documentation with `@./path/to/file.md` syntax (Android Studio Gemini, some others). This is **not universally supported** — use standard Markdown for maximum compatibility.

### Context Window Sizes

| Tool | Tokens | Implication |
|------|--------|-------------|
| OpenAI Codex | 128k–192k | Keep AGENTS.md lean |
| Claude Opus 4 | 200k | Room for larger files |
| GitHub Copilot | ~128k (varies by model) | Prefer minimal |
| Gemini | 1M–2M | Most room, don't waste it |

### Context Strategies

- **Proximity-based**: closer or nested files prioritized
- **Relevance-based**: AI decides what's important from file descriptions
- **@-mentions**: force inclusion of specific files
- **Trimming**: auto-removes older context as limits approach
- **Merging**: combines parent and child rules hierarchically

### Search Methods

Tools combine multiple search approaches. Optimize AGENTS.md for all:

- **Text-based** (grep, ripgrep): fast exact matches → use clear, searchable keywords
- **Semantic** (vector embeddings): finds conceptually related content → provide explicit concepts
- **AST-based**: parses code structure for language-aware results → provide explicit file paths and patterns
