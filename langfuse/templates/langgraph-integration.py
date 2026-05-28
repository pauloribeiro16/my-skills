"""
LangGraph Integration with Langfuse

This template demonstrates how to instrument a LangGraph workflow
using the Langfuse callback handler for full observability of
agent steps, tool calls, and LLM generations.
"""

import os
from typing import TypedDict, Annotated
from langchain_openai import ChatOpenAI
from langchain_core.messages import HumanMessage, AIMessage, ToolMessage
from langchain_core.tools import tool
from langgraph.graph import StateGraph, END
from langgraph.checkpoint.memory import MemorySaver
from langfuse.callback import CallbackHandler

# ── Configuration ───────────────────────────────────────────────────────────

os.environ["LANGFUSE_SECRET_KEY"] = "sk-lf-..."
os.environ["LANGFUSE_PUBLIC_KEY"] = "pk-lf-..."
os.environ["LANGFUSE_HOST"] = "https://cloud.langfuse.com"
os.environ["OPENAI_API_KEY"] = "sk-..."

# ── Initialize Langfuse Callback ────────────────────────────────────────────

langfuse_handler = CallbackHandler(
    trace_name="langgraph-agent",
    user_id="user-456",
    session_id="session-xyz",
    tags=["agent", "production"],
)

# ── Define Tools ────────────────────────────────────────────────────────────

@tool
def search(query: str) -> str:
    """Search for information on the web."""
    # Mock implementation — replace with real search
    return f"Search results for: {query}"

@tool
def calculator(expression: str) -> str:
    """Evaluate a mathematical expression."""
    try:
        result = eval(expression)
        return str(result)
    except Exception as e:
        return f"Error: {e}"

tools = [search, calculator]

# ── Define Agent State ──────────────────────────────────────────────────────

class AgentState(TypedDict):
    messages: Annotated[list, "List of messages in the conversation"]

# ── Define LangGraph Workflow ───────────────────────────────────────────────

llm = ChatOpenAI(model="gpt-4o-mini", temperature=0).bind_tools(tools)

def agent_node(state: AgentState):
    """The main agent node that decides what to do next."""
    messages = state["messages"]
    response = llm.invoke(messages)
    return {"messages": messages + [response]}

def tool_node(state: AgentState):
    """Execute tools called by the agent."""
    messages = state["messages"]
    last_message = messages[-1]

    tool_calls = last_message.tool_calls
    tool_messages = []

    for tool_call in tool_calls:
        tool_name = tool_call["name"]
        tool_args = tool_call["args"]

        # Execute the tool
        selected_tool = {"search": search, "calculator": calculator}[tool_name]
        tool_output = selected_tool.invoke(tool_args)

        tool_messages.append(
            ToolMessage(content=tool_output, tool_call_id=tool_call["id"])
        )

    return {"messages": messages + tool_messages}

def should_continue(state: AgentState):
    """Determine if we should continue or end."""
    last_message = state["messages"][-1]
    if last_message.tool_calls:
        return "tools"
    return END

# Build the graph
workflow = StateGraph(AgentState)
workflow.add_node("agent", agent_node)
workflow.add_node("tools", tool_node)
workflow.set_entry_point("agent")
workflow.add_conditional_edges("agent", should_continue, {"tools": "tools", END: END})
workflow.add_edge("tools", "agent")

app = workflow.compile(checkpointer=MemorySaver())

# ── Run the Agent with Langfuse Tracing ─────────────────────────────────────

if __name__ == "__main__":
    config = {
        "callbacks": [langfuse_handler],
        "configurable": {"thread_id": "thread-1"},
    }

    inputs = {
        "messages": [HumanMessage(content="What is 125 * 37? Also, what's the latest news about AI?")]
    }

    # Stream the execution to see intermediate steps
    for event in app.stream(inputs, config=config):
        for node_name, node_output in event.items():
            print(f"\n--- Node: {node_name} ---")
            for msg in node_output.get("messages", []):
                print(f"  {type(msg).__name__}: {msg.content[:100]}...")

    # Flush Langfuse data
    langfuse_handler.flush()

# ── Expected Trace Structure ────────────────────────────────────────────────
#
# Trace: "langgraph-agent"
# ├── Span: "agent" (node execution)
# │   └── Generation: "gpt-4o-mini" (deciding to use tools)
# ├── Span: "tools" (node execution)
# │   ├── Span: "search" (tool execution)
# │   └── Span: "calculator" (tool execution)
# └── Span: "agent" (final response)
#     └── Generation: "gpt-4o-mini" (answering the user)
#
# All tool inputs/outputs and LLM calls are automatically captured.
