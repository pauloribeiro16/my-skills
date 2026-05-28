from typing import TypedDict, Annotated
from langgraph.graph import add_messages


class AgentState(TypedDict):
    """State schema for the agent."""
    messages: Annotated[list, add_messages]
    """Conversation history with automatic message deduplication."""

    # Add custom fields as needed:
    # query: str
    # result: str
    # iteration_count: int = 0
