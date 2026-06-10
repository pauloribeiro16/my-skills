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
| **`frontend-design`** | Design de interfaces web — layouts, componentes, estilos |
| **`theme-factory`** | Criar temas personalizados — paletas de cores, tipografia, componentes |
| **`slack-gif-creator`** | Criar GIFs otimizados para Slack e outras plataformas |
| **`brand-guidelines`** | Guidelines de marca — logos, cores, tipografia, voz da marca |

---

## Desenvolvimento & Técnico

Skills para programação e ferramentas de desenvolvimento.

| Skill | Descrição |
|-------|-----------|
| **`mcp-builder`** | Construir servidores MCP (Model Context Protocol) |
| **`web-artifacts-builder`** | Construir web artifacts — componentes HTML/CSS/JS interativos |
| **`webapp-testing`** | Testar aplicações web — testes de UI, API, performance |
| **`skill-creator`** | Criar novas skills — estrutura, validação, melhores práticas |
| **`codebase-architecture`** | Análise e melhoria de arquitetura de codebase — deepening, modularização, seams |
| **`python-best-practices`** | Boas práticas Python moderno — PEP 8, type hints, testes, tooling |

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
| **`sprint-contract`** | Contratos de implementação com validation tiers (T1-T4), pass@k trials, e phased decomposition |
| **`agents-md-writer`** | Escrever ficheiros AGENTS.md e CLAUDE.md para projetos |
| **`context-checkpoint`** | Checkpoint de contexto para sessões longas (>70% context window) |
| **`etl-runner`** | Execução de ETL com fases sequenciais, tenant isolation e verificação de dados |
| **`eval-runner`** | Avaliação progressiva de tarefas (1→3→5), gestão de trials e timeouts |
| **`service-verify`** | Verificação de configurações de serviços — deteção de endpoints hardcoded |

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
