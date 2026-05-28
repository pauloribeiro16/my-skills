---
name: langgraph
description: |
  LangGraph skill for building stateful, multi-actor agent workflows with persistence.
  Triggers on: setup langgraph, create agent workflow, build graph, state machine,
  langgraph agent, agent with tools, human-in-the-loop, langchain graph.
---

# LangGraph

Build stateful agent workflows with LangGraph.

## When to Use

Use this skill when the user asks to:

- "setup langgraph"
- "create agent workflow"
- "build graph"
- "state machine"
- "langgraph agent"
- "agent with tools"
- "human-in-the-loop"
- "langchain graph"
- "persist agent state"
- "build multi-step LLM workflow"

## What It Covers

1. **Install and configure LangGraph**
   - `pip install langgraph langchain langchain-openai`
   - Setup environment variables (OPENAI_API_KEY)

2. **Define state schemas**
   - `TypedDict` for structured state
   - `MessagesState` for conversational agents
   - Custom reducers for state updates

3. **Create nodes and edges**
   - StateGraph builder
   - Conditional edges (routing)
   - Entry points and END nodes

4. **Build agent with tools**
   - Tool binding to LLM
   - ToolNode for execution
   - ReAct loop pattern

5. **Persist state with checkpoints**
   - InMemorySaver for dev/testing
   - SqliteSaver for local persistence
   - PostgresSaver for production

6. **Implement human-in-the-loop**
   - Interrupt before/after nodes
   - Resume execution with new state
   - Approval workflows

## Templates

- `templates/graph.py` — Main graph definition (StateGraph, edges, compilation)
- `templates/state.py` — State schema (TypedDict, MessagesState)
- `templates/nodes/llm_nodes.py` — LLM call nodes
- `templates/nodes/tools.py` — Tool definitions and ToolNode

## Resources

- `references/state-management.md` — TypedDict, reducers, MessagesState patterns
- `references/persistence.md` — Checkpoints (InMemory, SQLite, Postgres)
- `references/patterns.md` — Agent, Supervisor, Orchestrator-Worker, Evaluator-Optimizer

## Examples

- `examples/agent-with-tools.py` — Complete agent with tools, routing, and persistence

## Use When

The user wants to build a stateful, multi-step agent workflow using LangGraph with nodes, edges, tool use, and optional human-in-the-loop or persistence.
