---
name: langchain
description: >
  Use this skill when the user asks to setup LangChain, create a chain, build a RAG
  application, configure an LLM provider (OpenAI, Anthropic, local models), create
  custom tools, or work with LangChain Expression Language (LCEL). Triggers include:
  "setup langchain", "create chain", "build RAG", "configure LLM provider",
  "LCEL", "langchain prompt", "langchain model", "retriever", "vector store".
---

# LangChain Skill

## When to Use

- "setup langchain"
- "create chain"
- "build RAG"
- "configure LLM provider"
- "langchain model"
- "LCEL chain"
- "langchain prompt template"
- "retriever setup"
- "vector store"
- "custom tool"

## What It Covers

1. **Install and configure LangChain (v0.3+)**
   - Core packages: `langchain`, `langchain-core`, `langchain-community`
   - Provider-specific packages (e.g., `langchain-openai`, `langchain-anthropic`)
   - Environment variables for API keys

2. **Create chains with LCEL (LangChain Expression Language)**
   - Pipe operator (`|`)
   - `RunnablePassthrough`, `RunnableLambda`, `RunnableParallel`
   - Composing complex pipelines declaratively

3. **Setup prompts and output parsers**
   - `ChatPromptTemplate` and `PromptTemplate`
   - Structured output with Pydantic
   - `StrOutputParser`, `JsonOutputParser`

4. **Configure LLM providers (OpenAI, Anthropic, local)**
   - `init_chat_model` for unified model initialization
   - Provider-specific configuration (temperature, max_tokens, base_url)
   - Local models via Ollama, llama.cpp, or vLLM

5. **Build RAG applications**
   - Document loaders and text splitters
   - Vector stores (Chroma, FAISS, Qdrant)
   - Retrievers and retrieval chains

6. **Create custom tools**
   - `@tool` decorator
   - Tool schemas with Pydantic
   - Binding tools to models

## Templates

| Template | Purpose |
|----------|---------|
| `templates/models.py` | Configure LLMs with `init_chat_model` |
| `templates/prompts.py` | Reusable prompt templates |
| `templates/chains.py` | LCEL chain examples |
| `templates/requirements.txt` | Required dependencies |

## Examples

| Example | Purpose |
|---------|---------|
| `examples/basic-chain.py` | Simple LCEL chain with prompt + model + parser |

## Resources

- [LangChain Documentation](https://python.langchain.com/docs/)
- [LCEL Documentation](https://python.langchain.com/docs/concepts/lcel/)
- [LangChain Templates GitHub](https://github.com/langchain-ai/langchain/tree/master/templates)

## Use When

The user wants to build LLM-powered applications with LangChain, including chains, RAG pipelines, agents, or custom tools. Use for both quick scripts and production-grade setups.
