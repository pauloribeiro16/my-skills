"""Basic LCEL chain example: prompt + model + parser."""

import os
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain.chat_models import init_chat_model


def main():
    # Set your API key or ensure it's in the environment
    # os.environ["OPENAI_API_KEY"] = "your-api-key"

    # Initialize model using the unified interface
    model = init_chat_model("gpt-4o-mini", model_provider="openai")

    # Create a prompt template
    prompt = ChatPromptTemplate.from_messages([
        ("system", "You are a helpful and concise assistant."),
        ("human", "{question}"),
    ])

    # Create an output parser
    parser = StrOutputParser()

    # Compose the chain using LCEL pipe operator
    chain = prompt | model | parser

    # Invoke the chain
    question = "What is LangChain Expression Language (LCEL)?"
    response = chain.invoke({"question": question})

    print(f"Question: {question}")
    print(f"Answer: {response}")

    # Batch invocation example
    questions = [
        {"question": "What is a prompt template?"},
        {"question": "What is an output parser?"},
    ]
    responses = chain.batch(questions)
    for q, r in zip(questions, responses):
        print(f"\nQ: {q['question']}\nA: {r}")


if __name__ == "__main__":
    main()
