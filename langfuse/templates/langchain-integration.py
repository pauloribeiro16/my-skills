"""
LangChain Integration with Langfuse

This template demonstrates how to instrument a LangChain application
using the Langfuse callback handler for automatic tracing.
"""

import os
from langchain_openai import ChatOpenAI
from langchain.prompts import ChatPromptTemplate
from langchain.chains import LLMChain
from langfuse.callback import CallbackHandler

# ── Configuration ───────────────────────────────────────────────────────────

# Set your Langfuse credentials
os.environ["LANGFUSE_SECRET_KEY"] = "sk-lf-..."
os.environ["LANGFUSE_PUBLIC_KEY"] = "pk-lf-..."
os.environ["LANGFUSE_HOST"] = "https://cloud.langfuse.com"  # or your self-hosted URL

# Set your OpenAI API key (or other LLM provider)
os.environ["OPENAI_API_KEY"] = "sk-..."

# ── Initialize Langfuse Callback ────────────────────────────────────────────

langfuse_handler = CallbackHandler(
    # Optional: override env vars or add metadata
    trace_name="langchain-chat",
    user_id="user-123",
    session_id="session-abc",
    tags=["production", "v2"],
    metadata={"app_version": "1.0.0"},
)

# ── Create a Simple Chain ───────────────────────────────────────────────────

prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a helpful assistant."),
    ("human", "{question}"),
])

llm = ChatOpenAI(model="gpt-4o-mini", temperature=0.7)

chain = prompt | llm

# ── Run with Langfuse Tracing ───────────────────────────────────────────────

if __name__ == "__main__":
    question = "What are the main features of Langfuse?"

    # Pass the callback handler to automatically trace the chain execution
    response = chain.invoke(
        {"question": question},
        config={"callbacks": [langfuse_handler]},
    )

    print(f"Response: {response.content}")

    # Flush to ensure all data is sent to Langfuse before the script exits
    langfuse_handler.flush()

# ── Advanced: Tracing Multiple Steps ────────────────────────────────────────
#
# For more complex pipelines (RAG, agents), the callback handler
# automatically creates nested spans for each component:
#
#   Trace: "langchain-chat"
#   ├── Span: "ChatPromptTemplate"
#   ├── Span: "ChatOpenAI"
#   │   └── Generation: "gpt-4o-mini"
#   └── Span: "OutputParser"
#
# Just pass the same callback handler to all invoke/run calls.
