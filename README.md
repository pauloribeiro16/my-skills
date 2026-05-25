# My Skills

Coleção de skills para OpenCode e Claude, adaptadas do repositório oficial da Anthropic (`anthropics/skills`).

## Estrutura

Este repositório contém skills organizadas por categoria para diferentes casos de uso.

---

## Documentos

Skills para manipulação de documentos Microsoft Office e PDFs.

| Skill | Descrição |
|-------|-----------|
| **`docx`** | Criar e editar documentos Word (.docx) — formatação, tabelas, estilos, cabeçalhos/rodapés |
| **`xlsx`** | Manipular folhas Excel (.xlsx) — fórmulas, gráficos, tabelas dinâmicas, formatação condicional |
| **`pdf`** | Criar e editar PDFs — extração de texto, anotações, formulários, mesclagem |
| **`pptx`** | Criar apresentações PowerPoint (.pptx) — slides, animações, gráficos, layouts |
| **`doc-coauthoring`** | Co-autoria de documentos com controlo de alterações e comentários |

---

## Design & Criativo

Skills para criação de conteúdo visual e design.

| Skill | Descrição |
|-------|-----------|
| **`algorithmic-art`** | Arte algorítmica — padrões, fractais, visualizações generativas |
| **`canvas-design`** | Design de canvas para web e aplicações |
| **`frontend-design`** | Design de interfaces web — layouts, componentes, estilos |
| **`theme-factory`** | Criar temas personalizados — paletas de cores, tipografia, componentes |
| **`slack-gif-creator`** | Criar GIFs otimizados para Slack e outras plataformas |
| **`brand-guidelines`** | Guidelines de marca — logos, cores, tipografia, voz da marca |

---

## Desenvolvimento & Técnico

Skills para programação e ferramentas de desenvolvimento.

| Skill | Descrição |
|-------|-----------|
| **`claude-api`** | Usar a API do Claude — autenticação, prompts, streaming, function calling |
| **`mcp-builder`** | Construir servidores MCP (Model Context Protocol) |
| **`web-artifacts-builder`** | Construir web artifacts — componentes HTML/CSS/JS interativos |
| **`webapp-testing`** | Testar aplicações web — testes de UI, API, performance |
| **`skill-creator`** | Criar novas skills — estrutura, validação, melhores práticas |

---

## Enterprise & Comunicação

Skills para ambientes empresariais e comunicação.

| Skill | Descrição |
|-------|-----------|
| **`internal-comms`** | Comunicações internas — newsletters, anúncios, atualizações de equipa |

---

## OpenCode Skills

Skills originais para OpenCode.

| Skill | Descrição |
|-------|-----------|
| **`feature-dev`** | Workflow de 7 fases para desenvolvimento de funcionalidades (Discovery, Exploration, Clarification, Design, Implementation, Review, Summary) |
| **`code-review`** | Code review automatizado com scoring de confiança (0-100) e múltiplos agentes |
| **`commit-workflow`** | Automatização de git — commits, push, criação de PRs, limpeza de branches |
| **`sprint-orchestrator`** | Orquestração de sprints complexos com múltiplos subagentes e quality gates |
| **`agents-md-writer`** | Escrever ficheiros AGENTS.md e CLAUDE.md para projetos |

---

## Como Usar

### No OpenCode

Coloca as skills em `~/.config/opencode/skills/`:

```bash
cp -r skills/* ~/.config/opencode/skills/
```

### No Claude (Desktop)

Coloca as skills em `~/.claude/skills/`:

```bash
cp -r skills/* ~/.claude/skills/
```

---

## Licença

As skills originais da Anthropic são disponibilizadas sob licenças específicas (ver cada skill individualmente). As skills do OpenCode são adaptações próprias.

---

## Créditos

- **Anthropic** — pelo repositório original [`anthropics/skills`](https://github.com/anthropics/skills)
- **OpenCode** — pela framework de skills
