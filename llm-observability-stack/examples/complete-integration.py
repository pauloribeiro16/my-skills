"""
Complete integration example: LangChain + LangGraph + Langfuse

This example demonstrates:
- LangChain for RAG chain and tools
- LangGraph for multi-step workflow with state
- Langfuse for end-to-end tracing
"""

import os
from typing import TypedDict, Annotated, Sequence
import operator

from langchain_openai import ChatOpenAI, OpenAIEmbeddings
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_community.vectorstores import Chroma
from langchain_core.documents import Document
from langchain.tools import tool
from langgraph.graph import StateGraph, END
from langfuse.callback import CallbackHandler


# ============================================
# 1. LangChain: Setup LLM, RAG, and Tools
# ============================================

llm = ChatOpenAI(model="gpt-4o-mini", temperature=0)
embeddings = OpenAIEmbeddings()

# Sample documents for RAG
docs = [
    Document(page_content="LangChain is a framework for building LLM applications."),
    Document(page_content="LangGraph is a library for building stateful agents with graphs."),
    Document(page_content="Langfuse provides observability for LLM applications."),
]

# Create vector store
vectorstore = Chroma.from_documents(docs, embeddings)
retriever = vectorstore.as_retriever(search_kwargs={"k": 2})

# RAG prompt
rag_prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a helpful assistant. Use the context to answer."),
    ("human", "Context: {context}\n\nQuestion: {question}")
])

# RAG chain
rag_chain = (
    {"context": retriever | (lambda docs: "\n\n".join(d.page_content for d in docs)),
     "question": lambda x: x["question"]}
    | rag_prompt
    | llm
    | StrOutputParser()
)

# Custom tool
@tool
def calculator(expression: str) -> str:
    """Evaluate a math expression."""
    try:
        return str(eval(expression))
    except Exception as e:
        return f"Error: {e}"


# ============================================
# 2. LangGraph: Define State and Workflow
# ============================================

class AgentState(TypedDict):
    question: str
    context: str
    answer: str
    needs_calculation: bool
    messages: Annotated[Sequence[str], operator.add]


def retrieve_node(state: AgentState):
    """Retrieve relevant documents."""
    docs = retriever.invoke(state["question"])
    context = "\n\n".join(d.page_content for d in docs)
    return {
        "context": context,
        "messages": [f"Retrieved {len(docs)} documents"]
    }


def generate_node(state: AgentState):
    """Generate answer using RAG chain."""
    answer = rag_chain.invoke({"question": state["question"]})
    return {
        "answer": answer,
        "messages": [f"Generated answer"]
    }


def check_calculation_node(state: AgentState):
    """Check if calculation is needed."""
    check_prompt = ChatPromptTemplate.from_messages([
        ("system", "Does this question require a mathematical calculation? Reply only YES or NO."),
        ("human", "{question}")
    ])
    check_chain = check_prompt | llm | StrOutputParser()
    result = check_chain.invoke({"question": state["question"]})
    needs_calc = "YES" in result.upper()
    return {
        "needs_calculation": needs_calc,
        "messages": [f"Calculation needed: {needs_calc}"]
    }


def calculate_node(state: AgentState):
    """Perform calculation if needed."""
    calc_prompt = ChatPromptTemplate.from_messages([
        ("system", "Convert this question into a math expression. Reply only the expression."),
        ("human", "{question}")
    ])
    calc_chain = calc_prompt | llm | StrOutputParser()
    expression = calc_chain.invoke({"question": state["question"]})
    result = calculator.invoke(expression)
    return {
        "answer": f"Calculation result: {result}",
        "messages": [f"Calculated: {expression} = {result}"]
    }


def route_calculation(state: AgentState):
    """Route to calculation or end."""
    if state["needs_calculation"]:
        return "calculate"
    return "generate"


# Build graph
builder = StateGraph(AgentState)
builder.add_node("retrieve", retrieve_node)
builder.add_node("check", check_calculation_node)
builder.add_node("generate", generate_node)
builder.add_node("calculate", calculate_node)

builder.set_entry_point("retrieve")
builder.add_edge("retrieve", "check")
builder.add_conditional_edges(
    "check",
    route_calculation,
    {"calculate": "calculate", "generate": "generate"}
)
builder.add_edge("calculate", END)
builder.add_edge("generate", END)

graph = builder.compile()


# ============================================
# 3. Langfuse: Setup Observability
# ============================================

langfuse_handler = CallbackHandler(
    public_key=os.getenv("LANGFUSE_PUBLIC_KEY", "pk-lf-..."),
    secret_key=os.getenv("LANGFUSE_SECRET_KEY", "sk-lf-..."),
    host=os.getenv("LANGFUSE_HOST", "https://cloud.langfuse.com"),
)


# ============================================
# 4. Execute with Full Tracing
# ============================================

if __name__ == "__main__":
    # Example 1: Question requiring RAG
    result = graph.invoke(
        {"question": "What is LangGraph used for?"},
        config={
            "callbacks": [langfuse_handler],
            "metadata": {"user_id": "user-123", "session_id": "session-456"}
        }
    )
    print("Answer:", result["answer"])
    print("Messages:", result["messages"])

    # Example 2: Question requiring calculation
    result2 = graph.invoke(
        {"question": "What is 15 * 23 + 7?"},
        config={
            "callbacks": [langfuse_handler],
            "metadata": {"user_id": "user-123", "session_id": "session-456"}
        }
    )
    print("Answer:", result2["answer"])
    print("Messages:", result2["messages"])
