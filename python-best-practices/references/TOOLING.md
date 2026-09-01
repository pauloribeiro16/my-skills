# Modern Python Tooling

Complete reference for setting up and using modern Python development tools.

## Project Setup with uv

[uv](https://docs.astral.sh/uv/) is the fastest Python package and project manager, written in Rust. It replaces pip, venv, pip-tools, and Poetry.

```bash
# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Create new project
uv init my-project
cd my-project

# Create virtual environment
uv venv

# Add dependencies
uv add fastapi httpx pydantic

# Add dev dependencies
uv add --dev pytest ruff mypy pytest-cov

# Run commands
uv run pytest
uv run ruff check
```

## pyproject.toml (PEP 621)

```toml
[project]
name = "my-project"
version = "0.1.0"
description = "A production-grade Python project"
authors = [{name = "Your Name", email = "you@example.com"}]
requires-python = ">=3.12"
dependencies = [
    "fastapi>=0.115",
    "httpx>=0.28",
    "pydantic>=2.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.3",
    "ruff>=0.7",
    "mypy>=1.13",
    "pytest-cov>=5.0",
    "pytest-asyncio>=0.24",
]

[dependency-groups]
dev = ["pytest", "ruff", "mypy", "pytest-cov", "pytest-asyncio"]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"
```

## Ruff Configuration

Ruff is an extremely fast Python linter and formatter written in Rust. It replaces flake8, isort, black, and pyupgrade.

```toml
[tool.ruff]
line-length = 88
target-version = "py312"

[tool.ruff.lint]
select = [
    "E",   # pycodestyle errors
    "F",   # pyflakes
    "I",   # isort
    "N",   # pep8-naming
    "W",   # pycodestyle warnings
    "B",   # flake8-bugbear
    "C4",  # flake8-comprehensions
    "UP",  # pyupgrade
    "RUF", # Ruff-specific
]
ignore = ["E501"]  # line too long (handled by formatter)

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
line-ending = "auto"
```

```bash
# Check code
ruff check .

# Auto-fix issues
ruff check --fix .

# Format code
ruff format .
```

## MyPy Configuration

```toml
[tool.mypy]
python_version = "3.12"
strict = true
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_any_unimported = false
ignore_missing_imports = false
no_implicit_optional = true
check_untyped_defs = true
```

```bash
# Check types
mypy src/

# Check with stricter settings
mypy --strict src/
```

## Pytest Configuration

```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = "test_*.py"
python_functions = "test_*"
addopts = "-v --tb=short --cov=src/"

[tool.coverage.run]
source = ["src"]
branch = true

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "if __name__ == .__main__.:",
    "raise NotImplementedError",
    "def __repr__",
    "if TYPE_CHECKING:",
]
```

## Pre-commit with prek

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.7.0
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.13.0
    hooks:
      - id: mypy
        args: [--strict]
        additional_dependencies: [pydantic]

  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v5.0.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
```

```bash
# Install hooks
pre-commit install

# Run on all files
pre-commit run --all-files
```
