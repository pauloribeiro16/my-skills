# Langfuse Evaluation

## Scores

Scores in Langfuse allow you to evaluate the quality of your LLM application outputs. They can be attached to traces, spans, or generations.

### Types of Scores

| Type | Description | Use Case |
|------|-------------|----------|
| `numeric` | Float value (e.g., 0.0 to 1.0) | Relevance score, latency percentile |
| `boolean` | True/False value | Pass/fail test |
| `categorical` | String category (e.g., "good", "bad", "neutral") | Human rating |
| `comment` | Free-text annotation | Detailed feedback |

### Creating Scores

Scores can be created via:

1. **SDK** — Programmatically from your application
2. **API** — HTTP API for external systems
3. **UI** — Manually in the Langfuse dashboard
4. **Evaluators** — Automated evaluation pipelines

## LLM-as-a-Judge

Langfuse supports evaluating outputs using another LLM as a judge.

### How It Works

1. Define an evaluation prompt that instructs the judge LLM
2. Provide the original input and output as context
3. The judge LLM returns a score or classification
4. Langfuse records the score and optionally the judge's reasoning

### Example Judge Prompt

```text
You are an expert evaluator. Rate the following assistant response on a scale of 1-5
based on helpfulness, accuracy, and tone.

User Query: {{input}}
Assistant Response: {{output}}

Return ONLY a JSON object: {"score": number, "reasoning": "string"}
```

### Best Practices

- Use a more capable model as the judge (e.g., GPT-4 for judging GPT-3.5 outputs)
- Include clear rubrics in the judge prompt
- Validate judge outputs and handle parsing errors gracefully
- Compare judge scores with human ratings to calibrate

## Datasets

Datasets in Langfuse help you organize test cases for systematic evaluation.

### Dataset Structure

| Component | Description |
|-----------|-------------|
| **Dataset** | Collection of related test items |
| **Dataset Item** | Single test case with input, expected output, and metadata |
| **Run** | Execution of a dataset against a specific model/prompt version |

### Workflow

1. **Create a dataset** from production traces or manual uploads
2. **Add items** with inputs and expected (or reference) outputs
3. **Run experiments** by processing dataset items through your application
4. **Compare runs** across different models, prompts, or configurations
5. **Analyze metrics** — aggregate scores, latency, cost per run

### Use Cases

- **Regression testing** — Ensure new deployments don't degrade quality
- **A/B testing** — Compare model versions or prompt strategies
- **Benchmarking** — Evaluate against standard datasets
- **Golden dataset** — Curated high-quality examples for continuous evaluation

## Automated Evaluation Pipeline

```
Production Trace
    ↓
Trigger (e.g., every 10th trace, or specific tag)
    ↓
LLM-as-a-Judge Evaluator
    ↓
Score Recorded in Langfuse
    ↓
Alert if score < threshold
    ↓
Review in Dashboard + Dataset Analysis
```

## Metrics to Track

| Metric | Type | Target |
|--------|------|--------|
| Latency | Numeric | < 2s for chat responses |
| Token usage | Numeric | Optimize for cost |
| Helpfulness | Numeric (1-5) | > 4.0 average |
| Hallucination | Boolean | < 5% false rate |
| User satisfaction | Categorical | > 80% "good" |
