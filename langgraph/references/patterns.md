# LangGraph Patterns

## 1. ReAct Agent

Tool-calling loop with LLM reasoning:

```
START → llm → tools? ──Yes──→ tool_node → llm → ...
          └───No────→ END
```

Implemented via conditional edges checking for `tool_calls`.

## 2. Supervisor

A central node routes tasks to specialized worker nodes:

```
START → supervisor → worker_A → supervisor → ...
                └─→ worker_B → supervisor
                └─→ END
```

Supervisor decides which worker to call next based on state.

## 3. Orchestrator-Worker

Orchestrator plans, workers execute in parallel, then synthesizer combines:

```
START → orchestrator → [worker_1, worker_2, worker_3] → synthesizer → END
```

Use `Send` API to dispatch parallel tasks dynamically.

## 4. Evaluator-Optimizer

Feedback loop for iterative improvement:

```
START → generator → evaluator ──Pass──→ END
                      └─Fail──→ generator (retry)
```

Great for code generation, writing, or structured output refinement.

## Choosing a Pattern

| Pattern | Use Case |
|---------|----------|
| **Agent (ReAct)** | General tool-using assistant |
| **Supervisor** | Multi-domain routing |
| **Orchestrator-Worker** | Parallel task decomposition |
| **Evaluator-Optimizer** | Quality-critical generation |

## Conditional Edges

```python
from typing import Literal

def router(state: State) -> Literal["tools", "__end__"]:
    last_message = state["messages"][-1]
    if last_message.tool_calls:
        return "tools"
    return "__end__"

workflow.add_conditional_edges("llm", router)
```
