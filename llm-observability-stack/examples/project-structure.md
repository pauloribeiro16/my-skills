# Recommended Project Structure

Directory layout for a maintainable LLM application using LangChain + LangGraph + Langfuse.

```
my-llm-app/
├── .env                          # Environment variables (API keys, Langfuse config)
├── requirements.txt              # All dependencies
├── README.md                     # Project documentation
│
├── src/
│   ├── __init__.py
│   │
│   ├── chains/                   # LangChain chains
│   │   ├── __init__.py
│   │   ├── rag_chain.py          # RAG implementation
│   │   ├── qa_chain.py           # Simple QA chain
│   │   └── prompts/              # Prompt templates
│   │       ├── rag_prompt.py
│   │       └── system_prompts.py
│   │
│   ├── graph/                    # LangGraph workflows
│   │   ├── __init__.py
│   │   ├── agent_graph.py        # Main agent graph
│   │   ├── state.py              # State schemas (TypedDict)
│   │   ├── nodes/                # Graph node functions
│   │   │   ├── __init__.py
│   │   │   ├── retrieve.py
│   │   │   ├── generate.py
│   │   │   └── validate.py
│   │   └── edges/                # Edge routing functions
│   │       ├── __init__.py
│   │       └── routers.py
│   │
│   ├── tools/                    # LangChain tools
│   │   ├── __init__.py
│   │   ├── search.py
│   │   ├── calculator.py
│   │   └── database.py
│   │
│   ├── models/                   # LLM model configuration
│   │   ├── __init__.py
│   │   ├── llm.py                # LLM initialization
│   │   └── embeddings.py         # Embeddings initialization
│   │
│   ├── vectorstore/              # Vector store setup
│   │   ├── __init__.py
│   │   ├── chroma_store.py
│   │   └── loaders.py            # Document loaders
│   │
│   └── observability/            # Langfuse configuration
│       ├── __init__.py
│       ├── langfuse_client.py    # Langfuse client setup
│       └── callbacks.py          # Callback handlers
│
├── tests/                        # Unit and integration tests
│   ├── test_chains.py
│   ├── test_graph.py
│   └── test_tools.py
│
└── scripts/                      # Utility scripts
    ├── ingest_data.py            # Data ingestion
    └── evaluate.py               # Evaluation script
```

## Key Principles

1. **Separation of concerns**: Each component (chains, graph, tools) in its own module
2. **Reusability**: Chains and tools are independent and can be used outside the graph
3. **Observability isolation**: Langfuse config is centralized and easily removable
4. **State as schema**: LangGraph state is defined in a single location
5. **Configuration via env**: All secrets and URLs in `.env` file

## Dependency Example

```txt
# requirements.txt
langchain>=0.3.0
langchain-openai>=0.2.0
langchain-community>=0.3.0
langgraph>=0.2.0
langfuse>=2.0.0
chromadb>=0.5.0
python-dotenv>=1.0.0
```
