# State Management in LangGraph

## TypedDict State

Use `TypedDict` for structured, type-safe state:

```python
from typing import TypedDict, Annotated
from langgraph.graph import add_messages

class AgentState(TypedDict):
    messages: Annotated[list, add_messages]
    query: str
    result: str
    iteration_count: int
```

## Reducers

Reducers control how state fields merge on parallel branches:

```python
from operator import add
from typing import Annotated

class State(TypedDict):
    # Concatenate lists
    items: Annotated[list, add]
    # Overwrite (default)
    name: str
```

Built-in reducers from `langgraph.graph`:

| Reducer | Behavior |
|---------|----------|
| `add_messages` | Append messages, handles duplicate IDs |

## MessagesState

Pre-built state for conversational agents:

```python
from langgraph.graph import MessagesState

class MyState(MessagesState):
    # Inherits messages field with add_messages reducer
    extra_field: str
```

## Custom Reducers

```python
def merge_lists(left: list, right: list) -> list:
    return left + right

class State(TypedDict):
    items: Annotated[list, merge_lists]
```

## Best Practices

- Keep state minimal and serializable
- Use `Annotated` for reducer binding
- Prefer `MessagesState` for chat agents
- Avoid storing large objects (embeddings, documents) in state
