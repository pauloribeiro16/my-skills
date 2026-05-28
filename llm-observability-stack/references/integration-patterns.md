# Integration Patterns

Common patterns for integrating LangChain + LangGraph + Langfuse.

## Pattern 1: Chain-as-Node

Use a LangChain chain directly as a LangGraph node.

```python
from langgraph.graph import StateGraph
from langchain_core.runnables import RunnablePassthrough

# LangChain chain
rag_chain = (
    RunnablePassthrough.assign(context=retriever)
    | prompt
    | llm
    | StrOutputParser()
)

# LangGraph node
def rag_node(state):
    result = rag_chain.invoke({"question": state["question"]})
    return {"answer": result}

builder = StateGraph(State)
builder.add_node("rag", rag_node)
```

## Pattern 2: Tool-Calling Agent in Graph

LangGraph manages the agent loop; LangChain provides tools.

```python
from langgraph.prebuilt import create_react_agent

# LangChain tools
tools = [search_tool, calculator_tool]

# LangGraph creates the agent graph automatically
agent = create_react_agent(llm, tools)
result = agent.invoke({"messages": [("user", "What's 2+2?")]})
```

## Pattern 3: Multi-Step Workflow with Observability

Langfuse traces the entire multi-step workflow.

```python
from langfuse.callback import CallbackHandler

# Single callback for the whole pipeline
langfuse_handler = CallbackHandler(
    public_key="pk-lf-...",
    secret_key="sk-lf-...",
    host="https://cloud.langfuse.com"
)

# LangGraph with Langfuse tracing
result = graph.invoke(
    {"input": "user question"},
    config={"callbacks": [langfuse_handler]}
)
```

## Anti-Patterns

### Anti-Pattern 1: Recreating Callbacks Per Node

**Don't**: Create a new Langfuse callback in every node.
**Do**: Pass one callback via `config` at graph invocation level.

### Anti-Pattern 2: Mixing State Shapes

**Don't**: Use different state schemas in LangGraph and LangChain without clear mapping.
**Do**: Define a single TypedDict/Schema and use it consistently.

### Anti-Pattern 3: Ignoring Async

**Don't**: Use `.invoke()` everywhere in async applications.
**Do**: Use `.ainvoke()` or `.astream()` with proper async Langfuse callbacks.

## State Management Best Practices

1. **Define state schema upfront**: Use `TypedDict` or Pydantic models
2. **Keep state minimal**: Only store what's needed for routing and output
3. **Use reducers for lists**: `Annotated[list, operator.add]` for message history
4. **Document state fields**: Every field should have a clear purpose

## Observability Best Practices

1. **One callback per request**: Reuse the same Langfuse handler for the full graph execution
2. **Add metadata**: Include user_id, session_id, and request_id for filtering
3. **Create scores**: Add evaluation scores for important outputs
4. **Use tags**: Tag traces by environment (dev/staging/prod)
