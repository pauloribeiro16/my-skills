# Langfuse Tracing Guide

## Core Concepts

### Trace
A **trace** represents a single request or execution flow through your application. It is the top-level container that groups related spans and generations together.

- Analogous to a distributed trace in OpenTelemetry
- Contains metadata: `name`, `userId`, `sessionId`, `tags`, `metadata`
- Has a start time and end time

### Span
A **span** represents a unit of work within a trace (e.g., a function call, a retrieval step, a tool execution).

- Can be nested to represent hierarchical relationships
- Contains: `name`, `input`, `output`, `startTime`, `endTime`, `metadata`
- Analogous to spans in OpenTelemetry

### Generation
A **generation** is a special type of span that represents an LLM call.

- Captures: `model`, `prompt`, `completion`, `usage` (tokens), `cost`
- Supports streaming responses
- Can be linked to a prompt version

### Event
An **event** is an instantaneous occurrence within a trace or span.

- Used for logging specific moments (e.g., "retrieval completed", "cache hit")
- Contains: `name`, `timestamp`, `metadata`

## Attributes

### Common Attributes

| Attribute | Description | Example |
|-----------|-------------|---------|
| `name` | Human-readable identifier | `"chat-completion"` |
| `input` | Input data (string or JSON) | User message |
| `output` | Output data (string or JSON) | Assistant response |
| `metadata` | Arbitrary key-value pairs | `{"temperature": 0.7}` |
| `tags` | List of string labels | `["production", "v2"]` |
| `userId` | End-user identifier | `"user-123"` |
| `sessionId` | Session identifier | `"session-abc"` |

### Generation-Specific Attributes

| Attribute | Description |
|-----------|-------------|
| `model` | Model name (e.g., `gpt-4`, `claude-3-opus`) |
| `modelParameters` | Generation parameters (temperature, max_tokens, etc.) |
| `usage` | Token usage: `{input: 10, output: 20, total: 30}` |
| `cost` | Estimated cost in USD |

## Best Practices

1. **Always create a trace** as the root container for each user request
2. **Use descriptive names** for spans and generations
3. **Capture inputs and outputs** for debugging and evaluation
4. **Add metadata** for filtering and analysis in the Langfuse UI
5. **Use tags** to mark environments (`production`, `staging`, `development`)
6. **Group by session** when tracking multi-turn conversations
7. **End spans explicitly** or use context managers to ensure proper timing

## Example Structure

```
Trace: "chat-request-123"
├── Span: "retrieve-context"
│   ├── Event: "query-embedding-generated"
│   └── Event: "documents-retrieved"
├── Generation: "llm-completion"
│   ├── Input: system prompt + user message + retrieved context
│   └── Output: assistant response
└── Span: "post-process"
    └── Event: "response-formatted"
```
