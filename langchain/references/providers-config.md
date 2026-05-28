# LLM Providers Configuration

LangChain supports multiple LLM providers through provider-specific packages.

## Unified Initialization (Recommended)

```python
from langchain.chat_models import init_chat_model

model = init_chat_model("gpt-4o", model_provider="openai")
model = init_chat_model("claude-3-5-sonnet-20241022", model_provider="anthropic")
model = init_chat_model("llama3.1", model_provider="ollama")
```

## OpenAI

**Package:** `langchain-openai`

```python
from langchain_openai import ChatOpenAI

model = ChatOpenAI(
    model="gpt-4o",
    temperature=0.7,
    max_tokens=1024,
    api_key="sk-...",  # or set OPENAI_API_KEY env var
)
```

**Environment:**
```bash
export OPENAI_API_KEY="sk-..."
export OPENAI_BASE_URL="https://api.openai.com/v1"  # Optional (for proxies)
```

## Anthropic

**Package:** `langchain-anthropic`

```python
from langchain_anthropic import ChatAnthropic

model = ChatAnthropic(
    model="claude-3-5-sonnet-20241022",
    temperature=0.7,
    max_tokens=1024,
    api_key="sk-ant-...",  # or set ANTHROPIC_API_KEY env var
)
```

**Environment:**
```bash
export ANTHROPIC_API_KEY="sk-ant-..."
```

## Local Models (Ollama)

**Package:** `langchain-ollama`

```python
from langchain_ollama import ChatOllama

model = ChatOllama(
    model="llama3.1",
    temperature=0.7,
    base_url="http://localhost:11434",  # Default Ollama URL
)
```

## Local Models (vLLM / OpenAI-compatible)

```python
from langchain_openai import ChatOpenAI

model = ChatOpenAI(
    model="meta-llama/Meta-Llama-3.1-8B-Instruct",
    base_url="http://localhost:8000/v1",
    api_key="not-needed",
    temperature=0.7,
)
```

## Google (Gemini)

**Package:** `langchain-google-genai`

```python
from langchain_google_genai import ChatGoogleGenerativeAI

model = ChatGoogleGenerativeAI(
    model="gemini-1.5-pro",
    temperature=0.7,
    google_api_key="...",
)
```

## Common Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `temperature` | Randomness (0-2) | 0.7 |
| `max_tokens` | Max output tokens | None |
| `top_p` | Nucleus sampling | 1.0 |
| `frequency_penalty` | Penalize repetition | 0.0 |
| `presence_penalty` | Penalize new topics | 0.0 |

## Best Practices

1. Use environment variables for API keys
2. Use `init_chat_model` for provider-agnostic code
3. Set `base_url` for self-hosted or proxy endpoints
4. Configure timeouts for production deployments
5. Use streaming for better UX in interactive apps
