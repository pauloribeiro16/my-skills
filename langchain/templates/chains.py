"""LCEL chain examples demonstrating composition patterns."""

from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser, JsonOutputParser
from langchain_core.runnables import RunnablePassthrough, RunnableLambda, RunnableParallel
from langchain.chat_models import init_chat_model


model = init_chat_model("gpt-4o-mini", model_provider="openai")


# --- Simple chain: prompt -> model -> parser ---

simple_prompt = ChatPromptTemplate.from_template("Tell me a fun fact about {topic}")
simple_chain = simple_prompt | model | StrOutputParser()


# --- Chain with context augmentation ---

def get_context(query: str) -> str:
    """Simulate a retriever."""
    return f"Context for: {query}"

context_prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a helpful assistant."),
    ("human", "Context: {context}\n\nQuestion: {question}"),
])

context_chain = (
    RunnablePassthrough.assign(context=RunnableLambda(get_context))
    | context_prompt
    | model
    | StrOutputParser()
)


# --- Parallel chain: run two tasks at once ---

joke_prompt = ChatPromptTemplate.from_template("Tell me a joke about {topic}")
poem_prompt = ChatPromptTemplate.from_template("Write a haiku about {topic}")

parallel_chain = RunnableParallel(
    joke=joke_prompt | model | StrOutputParser(),
    poem=poem_prompt | model | StrOutputParser(),
)


# --- Chain with conditional logic ---

def route_input(data: dict) -> str:
    """Route to different prompts based on input."""
    if data.get("style") == "formal":
        return "formal"
    return "casual"

formal_prompt = ChatPromptTemplate.from_template("Formal response to: {query}")
casual_prompt = ChatPromptTemplate.from_template("Casual response to: {query}")

branch_chain = (
    RunnablePassthrough()
    | RunnableLambda(route_input)
    | {
        "formal": formal_prompt | model | StrOutputParser(),
        "casual": casual_prompt | model | StrOutputParser(),
    }
)


# --- Structured output chain ---

from pydantic import BaseModel, Field

class MovieReview(BaseModel):
    title: str = Field(description="Movie title")
    rating: int = Field(description="Rating from 1 to 10")
    summary: str = Field(description="Brief review summary")

structured_prompt = ChatPromptTemplate.from_template(
    "Review the movie '{title}' and provide structured output."
)
structured_chain = structured_prompt | model.with_structured_output(MovieReview)


# Example usage
if __name__ == "__main__":
    print(simple_chain.invoke({"topic": "space"}))
    print(context_chain.invoke({"question": "What is LangChain?"}))
    print(parallel_chain.invoke({"topic": "cats"}))
