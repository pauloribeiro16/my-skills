"""
Full Observability Example with Langfuse

This example demonstrates a complete LLM application with:
- Manual tracing with nested spans
- LLM generation tracking
- Custom scores and evaluations
- Tool/retrieval instrumentation
- Error handling and event logging
"""

import os
import time
import random
from datetime import datetime
from langfuse import Langfuse

# ── Configuration ───────────────────────────────────────────────────────────

os.environ["LANGFUSE_SECRET_KEY"] = "sk-lf-..."
os.environ["LANGFUSE_PUBLIC_KEY"] = "pk-lf-..."
os.environ["LANGFUSE_HOST"] = "https://cloud.langfuse.com"

langfuse = Langfuse()

# ── Mock Services ───────────────────────────────────────────────────────────

class MockVectorStore:
    """Mock vector store for document retrieval."""

    def search(self, query: str, top_k: int = 3):
        time.sleep(0.05)  # Simulate latency
        docs = [
            {"id": 1, "content": "Langfuse is an open-source LLM engineering platform."},
            {"id": 2, "content": "It provides observability, evaluation, and prompt management."},
            {"id": 3, "content": "Langfuse supports tracing, scoring, and dataset management."},
        ]
        return docs[:top_k]

class MockLLM:
    """Mock LLM for demonstration."""

    def __init__(self, model: str):
        self.model = model

    def generate(self, prompt: str):
        time.sleep(0.2)  # Simulate LLM latency
        return {
            "content": f"Based on the context, Langfuse is a comprehensive platform for LLM observability and evaluation.",
            "usage": {"input": len(prompt.split()), "output": 18, "total": len(prompt.split()) + 18},
        }

vector_store = MockVectorStore()
llm = MockLLM(model="gpt-4o")

# ── Application Code ────────────────────────────────────────────────────────

def retrieve_documents(query: str, parent_span):
    """Retrieve relevant documents for the query."""
    with parent_span.span(name="document-retrieval", input=query) as span:
        span.event(name="retrieval-start", metadata={"timestamp": datetime.utcnow().isoformat()})

        try:
            documents = vector_store.search(query, top_k=3)
            span.update(output={"documents": documents, "count": len(documents)})
            span.event(name="retrieval-complete", metadata={"doc_count": len(documents)})
            return documents
        except Exception as e:
            span.event(name="retrieval-error", metadata={"error": str(e)})
            raise

def generate_response(query: str, documents: list, parent_span):
    """Generate an LLM response using retrieved documents."""
    context = "\n".join([f"- {doc['content']}" for doc in documents])
    prompt = f"Context:\n{context}\n\nQuestion: {query}\n\nAnswer:"

    with parent_span.span(name="response-generation", input=prompt) as span:
        span.event(name="generation-start", metadata={"model": llm.model})

        try:
            result = llm.generate(prompt)

            span.generation(
                name="llm-call",
                model=llm.model,
                input=prompt,
                output=result["content"],
                usage=result["usage"],
                metadata={"temperature": 0.7},
            )

            span.update(output=result["content"])
            span.event(name="generation-complete", metadata={"latency_ms": 200})

            return result["content"]
        except Exception as e:
            span.event(name="generation-error", metadata={"error": str(e)})
            raise

def evaluate_response(query: str, response: str, parent_trace):
    """Score the response quality."""
    # Simulate evaluation logic
    relevance_score = random.uniform(0.7, 1.0)
    helpfulness_score = random.uniform(0.6, 1.0)

    parent_trace.score(
        name="relevance",
        value=relevance_score,
        comment="Semantic relevance to the query",
    )

    parent_trace.score(
        name="helpfulness",
        value=helpfulness_score,
        comment="How helpful the response is to the user",
    )

    return {"relevance": relevance_score, "helpfulness": helpfulness_score}

def process_user_query(query: str, user_id: str, session_id: str):
    """Process a user query with full observability."""

    with langfuse.trace(
        name="user-query-processing",
        user_id=user_id,
        session_id=session_id,
        input=query,
        tags=["production", "v2.1.0"],
        metadata={
            "app_version": "2.1.0",
            "environment": "production",
            "feature_flags": {"new_retrieval": True},
        },
    ) as trace:
        # Step 1: Retrieve documents
        documents = retrieve_documents(query, trace)

        # Step 2: Generate response
        response = generate_response(query, documents, trace)

        # Step 3: Update trace with final output
        trace.update(output=response)

        # Step 4: Evaluate and score
        scores = evaluate_response(query, response, trace)

        return {
            "response": response,
            "documents": documents,
            "scores": scores,
        }

# ── Main ────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Simulate multiple user queries
    queries = [
        "What is Langfuse and what does it do?",
        "How can I trace my LLM application?",
    ]

    for i, query in enumerate(queries):
        print(f"\n{'='*60}")
        print(f"Query {i+1}: {query}")
        print(f"{'='*60}")

        result = process_user_query(
            query=query,
            user_id=f"user-{1000 + i}",
            session_id=f"session-{datetime.now().strftime('%Y%m%d')}",
        )

        print(f"Response: {result['response']}")
        print(f"Documents retrieved: {len(result['documents'])}")
        print(f"Scores: {result['scores']}")

    # Flush all events
    langfuse.flush()
    print("\n✓ All traces flushed to Langfuse")

# ── Expected Trace Structure ────────────────────────────────────────────────
#
# Trace: "user-query-processing"
# ├── Metadata: user_id, session_id, tags, custom metadata
# ├── Span: "document-retrieval"
# │   ├── Event: "retrieval-start"
# │   ├── Event: "retrieval-complete"
# │   └── Output: documents list
# ├── Span: "response-generation"
# │   ├── Event: "generation-start"
# │   ├── Generation: "llm-call" (model, prompt, completion, usage, cost)
# │   ├── Event: "generation-complete"
# │   └── Output: response text
# ├── Score: "relevance" = 0.92
# ├── Score: "helpfulness" = 0.88
# └── Output: final response
#
# This structure provides complete visibility into every step of your
# LLM application, enabling debugging, optimization, and evaluation.
