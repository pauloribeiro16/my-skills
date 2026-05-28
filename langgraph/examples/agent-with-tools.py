"""
Complete LangGraph agent with tools, routing, and persistence.

Usage:
    export OPENAI_API_KEY=...
    python agent-with-tools.py
"""

import os
from typing import Annotated, TypedDict

from langchain_core.messages import HumanMessage, SystemMessage
from langchain_core.tools import tool
from langchain_openai import ChatOpenAI
from langgraph.checkpoint.memory import InMemorySaver
from langgraph.graph import StateGraph, END, add_messages
from langgraph.prebuilt import ToolNode


# ── State ──────────────────────────────────────────────────────────────

class AgentState(TypedDict):
    messages: Annotated[list, add_messages]


# ── Tools ──────────────────────────────────────────────────────────────

@tool
def search(query: str) -> str:
    """Search for information on the web."""
    return f"[Mock search results for: '{query}']"


@tool
def calculator(expression: str) -> str:
    """Evaluate a mathematical expression safely."""
    allowed_names = {"__builtins__": {}}
    try:
        return str(eval(expression, allowed_names, {}))
    except Exception as e:
        return f"Error evaluating expression: {e}"


tools = [search, calculator]
tool_node = ToolNode(tools)


# ── Nodes ──────────────────────────────────────────────────────────────

llm = ChatOpenAI(model="gpt-4o-mini", temperature=0).bind_tools(tools)


def llm_node(state: AgentState) -> dict:
    """Call the LLM with current messages."""
    response = llm.invoke(state["messages"])
    return {"messages": [response]}


# ── Routing ────────────────────────────────────────────────────────────

def should_call_tools(state: AgentState) -> str:
    """Route to tools if the last message has tool calls."""
    last_message = state["messages"][-1]
    if last_message.tool_calls:
        return "tools"
    return END


# ── Graph ──────────────────────────────────────────────────────────────

workflow = StateGraph(AgentState)

workflow.add_node("llm", llm_node)
workflow.add_node("tools", tool_node)

workflow.set_entry_point("llm")

workflow.add_conditional_edges(
    "llm",
    should_call_tools,
    {"tools": "tools", END: END}
)

workflow.add_edge("tools", "llm")

# Compile with in-memory checkpointing for demonstration
memory = InMemorySaver()
graph = workflow.compile(checkpointer=memory)


# ── Run ────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    if not os.environ.get("OPENAI_API_KEY"):
        print("Error: Set OPENAI_API_KEY environment variable.")
        exit(1)

    system_message = SystemMessage(content="You are a helpful assistant with access to search and calculator tools.")
    user_message = HumanMessage(content="What is the capital of France and what is 15 * 23?")

    config = {"configurable": {"thread_id": "demo-thread-1"}}

    result = graph.invoke(
        {"messages": [system_message, user_message]},
        config=config
    )

    for msg in result["messages"]:
        print(f"[{msg.type.upper()}]: {msg.content}")
