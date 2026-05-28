# LCEL (LangChain Expression Language) Guide

LCEL is a declarative way to compose chains using the pipe operator `|` and Runnables.

## Core Concepts

### The Pipe Operator (`|`)

Chains components together. The output of the left side becomes the input of the right side.

```python
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI
from langchain_core.output_parsers import StrOutputParser

prompt = ChatPromptTemplate.from_template("Tell me a joke about {topic}")
model = ChatOpenAI()
parser = StrOutputParser()

chain = prompt | model | parser
result = chain.invoke({"topic": "cats"})
```

### RunnablePassthrough

Passes input through unchanged. Useful for branching or preserving original input.

```python
from langchain_core.runnables import RunnablePassthrough

chain = RunnablePassthrough() | model
# Equivalent to just model.invoke()
```

With assign to augment context:

```python
from langchain_core.runnables import RunnablePassthrough

chain = (
    RunnablePassthrough.assign(context=retriever)
    | prompt
    | model
    | parser
)
```

### RunnableLambda

Wraps a custom function as a Runnable.

```python
from langchain_core.runnables import RunnableLambda

def uppercase(text: str) -> str:
    return text.upper()

chain = prompt | model | RunnableLambda(uppercase)
```

### RunnableParallel

Runs multiple branches in parallel and merges outputs.

```python
from langchain_core.runnables import RunnableParallel

chain = RunnableParallel(
    joke=prompt1 | model1 | parser,
    poem=prompt2 | model2 | parser,
)
result = chain.invoke({"topic": "cats"})
# result["joke"] and result["poem"]
```

## Input/Output Types

| Method | Use Case |
|--------|----------|
| `.invoke(input)` | Single input |
| `.batch(inputs)` | Multiple inputs |
| `.stream(input)` | Streaming output |
| `.ainvoke(input)` | Async single input |
| `.abatch(inputs)` | Async batch |
| `.astream(input)` | Async streaming |

## Best Practices

1. Prefer LCEL over legacy `Chain` classes
2. Use type hints for `RunnableLambda` functions
3. Leverage `.assign()` for context injection
4. Use `RunnableParallel` for independent operations
5. Test chains step-by-step during development
