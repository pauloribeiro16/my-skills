---
name: langfuse
description: >
  Skill for setting up Langfuse observability, LLM tracing, monitoring, and evaluation.
  Use when asked to: setup langfuse, add observability, trace LLM, LLM monitoring,
  instrument LLM app, evaluate LLM output, manage prompts, self-host langfuse,
  langchain observability, langgraph tracing, or debug LLM behavior.
---

# Langfuse Skill

## When to Use

Use this skill when you need to:

- **Setup Langfuse** — Cloud or self-hosted observability platform
- **Add observability** — Instrument an LLM application with tracing and monitoring
- **Trace LLM** — Record LLM calls, inputs, outputs, latency, and costs
- **LLM monitoring** — Track production performance, errors, and usage patterns
- Evaluate LLM outputs with scores and datasets
- Manage prompts with version control

## What It Covers

1. **Install and configure Langfuse** (cloud or self-hosted)
2. **Trace LLM calls manually** with the Python SDK
3. **Integrate with LangChain** using the Langfuse callback handler
4. **Integrate with LangGraph** for agent and workflow tracing
5. **Create scores and evaluations** — manual, automated, and LLM-as-a-Judge
6. **Manage prompts** with version control and programmatic retrieval

## Templates

This skill provides ready-to-use templates:

| Template | Purpose |
|----------|---------|
| `templates/langchain-integration.py` | LangChain callback handler setup |
| `templates/langgraph-integration.py` | LangGraph graph instrumentation |
| `templates/manual-tracing.py` | Manual tracing with context managers |

## Examples

- `examples/full-observability.py` — Complete example with traces, spans, generations, and scores

## Resources

- [Langfuse Documentation](https://langfuse.com/docs)
- [Langfuse GitHub](https://github.com/langfuse/langfuse)
- `references/tracing-guide.md` — Core concepts: traces, spans, generations, attributes
- `references/evaluation.md` — Scores, LLM-as-a-Judge, datasets
- `references/self-hosting.md` — Docker Compose setup with Postgres and Clickhouse

## Use When

The user asks anything about: setup langfuse, add observability, trace LLM, LLM monitoring, instrument LLM app, evaluate LLM output, manage prompts, self-host langfuse, langchain observability, langgraph tracing, or debug LLM behavior.
