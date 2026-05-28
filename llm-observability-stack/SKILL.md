---
name: llm-observability-stack
description: >
  Meta-skill for building a complete LLM application stack using LangChain + LangGraph + Langfuse.
  Use when asked to: integrate langchain langgraph langfuse, setup full LLM stack,
  build LLM app with observability, end-to-end LLM pipeline with tracing,
  production LLM stack, connect langchain with langgraph and langfuse,
  fullstack LLM observability, or setup RAG agent with monitoring.
---

# LLM Observability Stack

Complete integration of LangChain, LangGraph, and Langfuse for production-ready LLM applications with full observability.

## When to Use

- "integrate langchain langgraph langfuse"
- "setup full LLM stack"
- "build LLM app with observability"
- "end-to-end LLM pipeline with tracing"
- "production LLM stack"
- "connect langchain with langgraph and langfuse"
- "fullstack LLM observability"
- "setup RAG agent with monitoring"

## What It Covers

1. **Architecture overview** (LangChain + LangGraph + Langfuse)
   - How the three components connect
   - Data flow: user input -> LangGraph workflow -> LangChain chains/tools -> Langfuse tracing
   - When to use each component in the stack

2. **Project structure recommendation**
   - Directory layout for maintainable code
   - Separation of concerns: chains, graphs, tools, observability config

3. **Setup all 3 components together**
   - Combined dependency management
   - Environment configuration
   - Initialization order

4. **Integrate LangChain with LangGraph**
   - Using LangChain chains inside LangGraph nodes
   - Passing state between LangChain operations
   - Tool binding in graph workflows

5. **Add Langfuse observability to the stack**
   - Single Langfuse callback for the entire pipeline
   - Tracing across LangGraph state transitions
   - Cost and latency tracking end-to-end

6. **Best practices for production**
   - Error handling and fallback strategies
   - Async execution patterns
   - Resource cleanup and connection management

## Architecture

```
User Input
    |
    v
+---------------+
|   LangGraph   |  <-- State management, workflow orchestration
|    (Graph)    |      Conditional edges, loops, branching
+---------------+
    |
    v
+---------------+
|   LangChain   |  <-- Chains, RAG, tools, LLM calls
|   (Chains)    |      Prompts, retrievers, output parsers
+---------------+
    |
    v
+---------------+
|   Langfuse    |  <-- Tracing, monitoring, evaluation
| (Observability)|     Spans, generations, scores, datasets
+---------------+
```

### Component Responsibilities

| Component | Role | Example |
|-----------|------|---------|
| **LangChain** | Build chains, RAG, tools | `retrieval_chain`, `agent_executor` |
| **LangGraph** | Orchestrate workflow with state | `StateGraph` with conditional routing |
| **Langfuse** | Trace and monitor everything | Callback handler, manual traces |

### Integration Points

1. **LangChain + LangGraph**: LangChain chains/tools are used as node functions in LangGraph
2. **LangChain + Langfuse**: Langfuse callback handler automatically traces all LangChain operations
3. **LangGraph + Langfuse**: Langfuse traces the full graph execution including state transitions
4. **Full Stack**: One Langfuse callback traces the entire pipeline from graph entry to final output

## Templates

| Template | Purpose |
|----------|---------|
| `SKILL.md` | This skill definition |

## Examples

| Example | Purpose |
|---------|---------|
| `examples/complete-integration.py` | Full project using all 3 tools together |
| `examples/project-structure.md` | Recommended directory structure |

## References

- `references/integration-patterns.md` — Common integration patterns and anti-patterns
- `../langchain/SKILL.md` — LangChain individual skill (chains, RAG, tools)
- `../langgraph/SKILL.md` — LangGraph individual skill (state graphs, agents)
- `../langfuse/SKILL.md` — Langfuse individual skill (tracing, monitoring, evaluation)

## Resources

- [LangChain Documentation](https://python.langchain.com/docs/)
- [LangGraph Documentation](https://langchain-ai.github.io/langgraph/)
- [Langfuse Documentation](https://langfuse.com/docs)

## Use When

The user wants to build a complete, production-ready LLM application using LangChain for chains/RAG, LangGraph for workflow orchestration, and Langfuse for observability. This is the go-to skill for full-stack LLM development with monitoring.
