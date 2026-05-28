"""
Manual Tracing with Langfuse

This template demonstrates how to manually create traces, spans,
and generations using the Langfuse Python SDK with context managers.
"""

import os
from langfuse import Langfuse

# ── Configuration ───────────────────────────────────────────────────────────

os.environ["LANGFUSE_SECRET_KEY"] = "sk-lf-..."
os.environ["LANGFUSE_PUBLIC_KEY"] = "pk-lf-..."
os.environ["LANGFUSE_HOST"] = "https://cloud.langfuse.com"

langfuse = Langfuse()

# ── Example 1: Simple Trace with Generation ─────────────────────────────────

def simple_llm_call():
    with langfuse.trace(
        name="simple-chat",
        user_id="user-789",
        metadata={"app_version": "1.2.0"},
    ) as trace:
        # Simulate an LLM call
        prompt = "What is the capital of France?"
        completion = "The capital of France is Paris."

        trace.generation(
            name="gpt-4o-response",
            model="gpt-4o",
            input=prompt,
            output=completion,
            usage={"input": 8, "output": 7, "total": 15},
            metadata={"temperature": 0.5},
        )

        return completion

# ── Example 2: Nested Spans with Context Manager ────────────────────────────

def rag_pipeline():
    with langfuse.trace(
        name="rag-query",
        user_id="user-789",
        tags=["production", "rag"],
    ) as trace:
        query = "Explain quantum computing in simple terms"

        # Step 1: Retrieve documents
        with trace.span(
            name="retrieval",
            input=query,
        ) as retrieval_span:
            # Simulate document retrieval
            documents = [
                "Quantum computing uses qubits instead of bits...",
                "Superposition allows qubits to be in multiple states...",
            ]
            retrieval_span.update(output={"documents": documents, "count": len(documents)})

            retrieval_span.event(
                name="embedding-generated",
                metadata={"model": "text-embedding-3-small"},
            )

        # Step 2: Generate response
        with trace.span(
            name="generation",
            input={"query": query, "context": documents},
        ) as generation_span:
            prompt = f"Context: {documents}\n\nQuestion: {query}"
            completion = "Quantum computing is a new type of computing that uses quantum mechanics..."

            generation_span.generation(
                name="llm-completion",
                model="gpt-4o",
                input=prompt,
                output=completion,
                usage={"input": 150, "output": 50, "total": 200},
                metadata={"temperature": 0.7, "max_tokens": 500},
            )

        # Step 3: Add a score
        trace.score(
            name="relevance",
            value=0.95,
            comment="Highly relevant to the query",
        )

        return completion

# ── Example 3: Async Tracing ────────────────────────────────────────────────

import asyncio

async def async_llm_call():
    trace = langfuse.trace(name="async-chat", user_id="user-789")

    # Simulate async LLM call
    await asyncio.sleep(0.1)

    trace.generation(
        name="async-response",
        model="gpt-4o",
        input="Hello!",
        output="Hello! How can I assist you today?",
        usage={"input": 1, "output": 8, "total": 9},
    )

    trace.update()
    return "Hello! How can I assist you today?"

# ── Main ────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Run synchronous examples
    print("Simple call:", simple_llm_call())
    print("RAG pipeline:", rag_pipeline())

    # Run async example
    print("Async call:", asyncio.run(async_llm_call()))

    # Flush all pending events
    langfuse.flush()

# ── Best Practices ──────────────────────────────────────────────────────────
#
# 1. Always use context managers (`with`) for automatic timing and cleanup
# 2. End spans explicitly if not using context managers: `span.end()`
# 3. Call `langfuse.flush()` before script exit to ensure all data is sent
# 4. Use descriptive names that help you identify traces in the UI
# 5. Include user_id and session_id for user-level and session-level analysis
# 6. Add metadata for filtering: environment, model version, feature flags
# 7. Use tags to mark: production, staging, experiment, baseline
