from langchain_core.tools import tool
from langgraph.prebuilt import ToolNode


@tool
def search(query: str) -> str:
    """Search for information on the web."""
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
tool_node = ToolNode(tools)
