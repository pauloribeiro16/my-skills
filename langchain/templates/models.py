"""Model configuration templates using init_chat_model and provider-specific classes."""

from langchain.chat_models import init_chat_model
from langchain_openai import ChatOpenAI
from langchain_anthropic import ChatAnthropic
from langchain_ollama import ChatOllama


def get_openai_model(
    model_name: str = "gpt-4o",
    temperature: float = 0.7,
    max_tokens: int | None = None,
) -> ChatOpenAI:
    """Configure an OpenAI chat model."""
    return ChatOpenAI(
        model=model_name,
        temperature=temperature,
        max_tokens=max_tokens,
    )


def get_anthropic_model(
    model_name: str = "claude-3-5-sonnet-20241022",
    temperature: float = 0.7,
    max_tokens: int = 1024,
) -> ChatAnthropic:
    """Configure an Anthropic chat model."""
    return ChatAnthropic(
        model=model_name,
        temperature=temperature,
        max_tokens=max_tokens,
    )


def get_ollama_model(
    model_name: str = "llama3.1",
    temperature: float = 0.7,
    base_url: str = "http://localhost:11434",
) -> ChatOllama:
    """Configure a local Ollama chat model."""
    return ChatOllama(
        model=model_name,
        temperature=temperature,
        base_url=base_url,
    )


def get_model_unified(
    model: str,
    model_provider: str,
    **kwargs,
):
    """Initialize any supported chat model using the unified interface."""
    return init_chat_model(model, model_provider=model_provider, **kwargs)


# Example usage
if __name__ == "__main__":
    openai_model = get_openai_model(temperature=0.5)
    anthropic_model = get_anthropic_model()
    ollama_model = get_ollama_model(model_name="mistral")

    unified = get_model_unified("gpt-4o-mini", "openai", temperature=0.3)
