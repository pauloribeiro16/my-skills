"""Reusable prompt templates for common LLM tasks."""

from langchain_core.prompts import (
    ChatPromptTemplate,
    PromptTemplate,
    SystemMessagePromptTemplate,
    HumanMessagePromptTemplate,
    MessagesPlaceholder,
)


# --- System prompts ---

SYSTEM_EXPERT = SystemMessagePromptTemplate.from_template(
    "You are an expert in {domain}. Provide accurate, concise, and helpful responses."
)

SYSTEM_ASSISTANT = SystemMessagePromptTemplate.from_template(
    "You are a helpful AI assistant. Answer the user's questions clearly and concisely."
)


# --- Task-specific prompts ---

SUMMARIZE_PROMPT = ChatPromptTemplate.from_messages([
    SYSTEM_ASSISTANT,
    HumanMessagePromptTemplate.from_template(
        "Summarize the following text in {style} style:\n\n{text}"
    ),
])

TRANSLATE_PROMPT = ChatPromptTemplate.from_messages([
    SYSTEM_ASSISTANT,
    HumanMessagePromptTemplate.from_template(
        "Translate the following text from {source_lang} to {target_lang}:\n\n{text}"
    ),
])

EXTRACT_ENTITIES_PROMPT = ChatPromptTemplate.from_messages([
    SYSTEM_EXPERT,
    HumanMessagePromptTemplate.from_template(
        "Extract all named entities from the text below. "
        "Return a JSON list of objects with 'entity', 'type', and 'description' fields.\n\n{text}"
    ),
])

CLASSIFY_PROMPT = ChatPromptTemplate.from_messages([
    SYSTEM_ASSISTANT,
    HumanMessagePromptTemplate.from_template(
        "Classify the following text into one of these categories: {categories}.\n\n"
        "Text: {text}\n\nCategory:"
    ),
])


# --- Conversational prompts ---

CHAT_PROMPT = ChatPromptTemplate.from_messages([
    SYSTEM_ASSISTANT,
    MessagesPlaceholder(variable_name="history"),
    HumanMessagePromptTemplate.from_template("{input}"),
])


# --- RAG prompts ---

RAG_PROMPT = ChatPromptTemplate.from_messages([
    SYSTEM_ASSISTANT,
    HumanMessagePromptTemplate.from_template(
        "Use the following context to answer the question. "
        "If the answer is not in the context, say 'I don't know based on the provided context.'\n\n"
        "Context:\n{context}\n\n"
        "Question: {question}\n\n"
        "Answer:"
    ),
])


# --- String templates (for simple use cases) ---

QUESTION_ANSWER = PromptTemplate.from_template(
    "Question: {question}\n\nAnswer:"
)

JSON_OUTPUT = PromptTemplate.from_template(
    "{instructions}\n\nReturn the result as valid JSON.\n\nInput: {input}"
)


# Example usage
if __name__ == "__main__":
    prompt = SUMMARIZE_PROMPT.invoke({"style": "bullet points", "text": "LangChain is a framework..."})
    print(prompt)
