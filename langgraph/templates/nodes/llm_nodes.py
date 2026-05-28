from langchain_openai import ChatOpenAI
from state import AgentState


def llm_node(state: AgentState) -> dict:
    """Invoke the LLM with the current conversation history."""
    model = ChatOpenAI(model="gpt-4o-mini", temperature=0)

    # Bind tools (defined in nodes/tools.py)
    from nodes.tools import tools
    model_with_tools = model.bind_tools(tools)

    response = model_with_tools.invoke(state["messages"])
    return {"messages": [response]}
