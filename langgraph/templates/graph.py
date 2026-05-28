from langgraph.graph import StateGraph, END
from langgraph.checkpoint.memory import InMemorySaver
from state import AgentState
from nodes.llm_nodes import llm_node
from nodes.tools import tool_node


def build_graph(checkpointer=None):
    """Build and compile the agent graph."""
    workflow = StateGraph(AgentState)

    # Add nodes
    workflow.add_node("llm", llm_node)
    workflow.add_node("tools", tool_node)

    # Set entry point
    workflow.set_entry_point("llm")

    # Add conditional edges: route to tools if LLM requests tool calls
    workflow.add_conditional_edges(
        "llm",
        lambda state: "tools" if state["messages"][-1].tool_calls else END,
        {"tools": "tools", END: END}
    )

    # Tools always return to LLM for next reasoning step
    workflow.add_edge("tools", "llm")

    # Compile with optional checkpointer for persistence
    if checkpointer is None:
        checkpointer = InMemorySaver()

    return workflow.compile(checkpointer=checkpointer)


if __name__ == "__main__":
    graph = build_graph()
    # Example invocation:
    # from langchain_core.messages import HumanMessage
    # result = graph.invoke({"messages": [HumanMessage(content="Hello")]})
    # print(result)
