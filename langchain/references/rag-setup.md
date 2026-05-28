# RAG Setup Guide

Retrieval-Augmented Generation (RAG) combines document retrieval with LLM generation.

## Pipeline Overview

```
Documents -> Load -> Split -> Embed -> Store -> Retrieve -> Augment -> Generate
```

## 1. Document Loaders

```python
from langchain_community.document_loaders import TextLoader, PyPDFLoader

# Text files
loader = TextLoader("docs.txt")
docs = loader.load()

# PDF files
loader = PyPDFLoader("document.pdf")
docs = loader.load()
```

## 2. Text Splitters

```python
from langchain_text_splitters import RecursiveCharacterTextSplitter

splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000,
    chunk_overlap=200,
    separators=["\n\n", "\n", " ", ""]
)
chunks = splitter.split_documents(docs)
```

| Splitter | Best For |
|----------|----------|
| `RecursiveCharacterTextSplitter` | General text |
| `CharacterTextSplitter` | Fixed-size chunks |
| `MarkdownHeaderTextSplitter` | Markdown documents |
| `TokenTextSplitter` | Token-based splitting |

## 3. Embeddings

```python
from langchain_openai import OpenAIEmbeddings
from langchain_ollama import OllamaEmbeddings

# OpenAI
embeddings = OpenAIEmbeddings(model="text-embedding-3-small")

# Local (Ollama)
embeddings = OllamaEmbeddings(model="nomic-embed-text")
```

## 4. Vector Stores

```python
from langchain_chroma import Chroma
from langchain_community.vectorstores import FAISS

# Chroma
vectorstore = Chroma.from_documents(
    documents=chunks,
    embedding=embeddings,
    persist_directory="./chroma_db"
)

# FAISS
vectorstore = FAISS.from_documents(chunks, embeddings)
```

## 5. Retrievers

```python
# Basic similarity search
retriever = vectorstore.as_retriever(
    search_type="similarity",
    search_kwargs={"k": 4}
)

# MMR (Maximal Marginal Relevance) for diversity
retriever = vectorstore.as_retriever(
    search_type="mmr",
    search_kwargs={"k": 4, "fetch_k": 20, "lambda_mult": 0.5}
)

# Multi-query retriever
from langchain.retrievers.multi_query import MultiQueryRetriever
retriever = MultiQueryRetriever.from_llm(
    retriever=vectorstore.as_retriever(),
    llm=model
)
```

## 6. RAG Chain (LCEL)

```python
from langchain_core.runnables import RunnablePassthrough
from langchain_core.output_parsers import StrOutputParser
from langchain import hub

# Use a pre-built RAG prompt
prompt = hub.pull("rlm/rag-prompt")

rag_chain = (
    {"context": retriever | format_docs, "question": RunnablePassthrough()}
    | prompt
    | model
    | StrOutputParser()
)

def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)

response = rag_chain.invoke("What is the main topic?")
```

## Best Practices

1. Chunk size: 500-1000 tokens with 10-20% overlap
2. Use MMR when diversity matters
3. Add metadata filtering for domain-specific retrieval
4. Evaluate retrieval quality with relevance scores
5. Consider re-ranking for better context quality
