---
name: python-best-practices
description: "Expert guidance for Python best practices: PEP 8, type hints, testing, error handling, async patterns, modern tooling. Use when writing or refactoring Python code."
---

# Python Best Practices

Write idiomatic, maintainable, and production-ready Python code following modern standards and type-safe patterns.

## Quick Start

When writing or reviewing Python code, follow this checklist:

1. **Structure**: Use `src/` layout with `pyproject.toml` (PEP 621)
2. **Style**: Follow PEP 8 -- Ruff handles formatting automatically
3. **Types**: Add type hints to all function signatures (PEP 484)
4. **Tests**: Write tests with pytest before implementation (TDD)
5. **Errors**: Use specific exceptions and context managers
6. **Tools**: Run `ruff check`, `mypy`, and `pytest` before committing

## Core Principles

### 1. PEP 8 -- Style Guide

- 4 spaces per indentation level (never tabs)
- 88 char line length (Ruff default), 72 for docstrings
- `snake_case` for functions/variables, `PascalCase` for classes, `UPPER_CASE` for constants
- Imports: stdlib, third-party, local (each group separated by blank line)
- No wildcard imports (`from module import *`)

### 2. Type Hints (PEP 484 / 585 / 604)

- All function signatures must have type hints
- Use `list[X]` not `List[X]` (Python 3.9+)
- Use `X | None` not `Optional[X]` (Python 3.10+)
- Use `TypedDict` for structured dicts, `dataclasses` or `Pydantic` for data models
- Run `mypy --strict` to catch type errors

### 3. Readability and Clarity

- Write self-documenting code: descriptive names over comments
- Docstrings on all public functions (Args, Returns, Raises)
- Prefer explicit over implicit -- no magic values, no bare `except:`

### 4. Error Handling

- Use specific exception classes, never bare `except:`
- Context managers for resource management (`with` blocks)
- Log exceptions with `logging.exception()` or `logger.exception()`
- Define custom exception hierarchies for domain errors

### 5. Testing (TDD)

- Write tests first, then implement, then refactor
- Use pytest with descriptive test function names
- Parametrize tests with `@pytest.mark.parametrize`
- One assertion per test where possible
- Aim for mutation testing coverage (see references/TESTING.md)

### 6. Modern Tooling

- **uv** for package management (replaces pip + venv + pip-tools)
- **Ruff** for linting + formatting (replaces flake8 + isort + black)
- **MyPy --strict** for type checking
- **pytest** for testing
- **pre-commit / prek** for git hooks

## References

| File | When to read |
|------|-------------|
| `references/TOOLING.md` | When setting up a new Python project. Complete tool configuration (pyproject.toml, Ruff, MyPy, pytest, uv). |
| `references/PATTERNS.md` | When writing Python code. Patterns for dataclasses, Pydantic, async/await, context managers, logging, CLI. |
| `references/TESTING.md` | When writing or improving tests. pytest, Hypothesis, mocking, async testing, mutation testing. |

## Common Pitfalls

- **Mutable default arguments**: Use `None` and check inside the function
- **Bare except clauses**: Always specify `Exception` or a concrete type
- **Ignoring type hints**: `Any` should be a last resort, not the default
- **Over-abstracting**: Don't add interfaces/ABCs until you have at least two implementations
- **Mixing sync and async**: Don't call async code from sync without an event loop
- **Neglecting `__pycache__`**: Add to `.gitignore`
