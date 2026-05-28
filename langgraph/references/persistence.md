# Persistence & Checkpoints

## Overview

LangGraph supports saving and resuming graph execution via **checkpointers**.

## InMemorySaver (Development / Testing)

```python
from langgraph.checkpoint.memory import InMemorySaver

memory = InMemorySaver()
graph = workflow.compile(checkpointer=memory)
```

- Stores checkpoints in RAM
- Lost on process restart
- Perfect for quick tests

## SqliteSaver (Local Persistence)

```python
from langgraph.checkpoint.sqlite import SqliteSaver

with SqliteSaver.from_conn_string(":memory:") as memory:
    graph = workflow.compile(checkpointer=memory)
    # Or use a file:
    # SqliteSaver.from_conn_string("checkpoints.db")
```

- Persistent across restarts
- Good for single-node deployments

## PostgresSaver (Production)

```python
from langgraph.checkpoint.postgres import PostgresSaver

conn_string = "postgresql://user:pass@localhost/db"
with PostgresSaver.from_conn_string(conn_string) as memory:
    graph = workflow.compile(checkpointer=memory)
```

- Scalable, concurrent access
- Requires `pip install psycopg2` or `psycopg[binary]`

## Thread ID & Resume

```python
config = {"configurable": {"thread_id": "conversation-123"}}

# Run and save checkpoint
result = graph.invoke({"messages": [HumanMessage("hello")]}, config)

# Resume later with same thread_id
result2 = graph.invoke(None, config)
```

## Human-in-the-Loop with Interrupt

```python
# Interrupt before a node
graph = workflow.compile(checkpointer=memory, interrupt_before=["dangerous_action"])

# User approves and resumes
result = graph.invoke(None, config)  # Continues from interruption
```

## Best Practices

- Always set `thread_id` for resumable sessions
- Use `InMemorySaver` for unit tests
- Use `PostgresSaver` for production multi-user apps
- Combine `interrupt_before`/`interrupt_after` with checkpoints for HITL
