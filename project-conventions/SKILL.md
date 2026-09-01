---
name: project-conventions
description: "AEGIS-KG project conventions: naming, file structure, function patterns, error handling. Use when creating new modules, files, functions, or classes. Activated automatically when modifying core/, cases/, or any tracked Python file."
---

# AEGIS-KG Project Conventions

This skill enforces the AEGIS-KG project's specific conventions. Python best practices are enforced by `python-best-practices` skill; this skill covers the **project-specific patterns** not covered by generic Python rules.

**Activate this skill when:**
- Creating new Python modules or files
- Renaming functions, classes, or files
- Adding new patterns to existing modules
- Reviewing code for consistency

---

## 1. Naming Conventions

| Element | Convention | Example | Anti-pattern |
|---------|------------|---------|--------------|
| **Python files** | `snake_case.py` | `etl_utils.py`, `llm_factory.py` | `etlUtils.py`, `ETLUtils.py` |
| **Directories** | `kebab-case/` or `snake_case/` | `phase1/`, `etl_utils/`, `kg/` | `Phase1/`, `etl-utils/` mixed |
| **Classes** | `PascalCase` | `AegisSettings`, `Neo4jConfig`, `CaseConfig` | `aegis_settings`, `neo4j_config` |
| **Functions/Methods** | `snake_case` | `load_case_config`, `exec_cypher_http` | `loadCaseConfig`, `ExecCypher` |
| **Async functions** | `snake_case` (no prefix) | `async def fetch_user():` | `async def a_fetch_user():` (deprecated) |
| **Constants** | `UPPER_SNAKE_CASE` | `NEO4J_HTTP_URL`, `DEFAULT_LLM_MODEL` | `Neo4jHttpUrl`, `neo4j_http_url` |
| **Private** | `_leading_underscore` | `_safe_float`, `_parse_markdown_table` | `__double_underscore__` (reserved) |
| **Type variables** | `PascalCase` | `T`, `StateT`, `ConfigT` | `t`, `state_t` |
| **Enum members** | `UPPER_SNAKE_CASE` | `class Color(enum.Enum): RED = 1` | `class Color: Red = 1` |
| **Test functions** | `test_<behavior>` | `test_loads_yaml_with_env_expansion` | `test_load`, `test_1` |
| **Test classes** | `Test<ClassName>` | `TestCaseConfigLoader` | `TestCaseConfig`, `TestConfigTest` |

---

## 2. File Organization

### 2.1 Standard Module Structure

```python
"""<module_name> — <one-line purpose>.

<longer description if needed>

References:
    - specs-reference/code-patterns/CODE_TEMPLATES.md (if applicable)
    - execution/LESSONS.md (if relevant lessons)
"""

# ─── Standard library ────────────────────────────────────────────────
import json
import logging
import os
from pathlib import Path
from typing import TYPE_CHECKING

# ─── Third-party ─────────────────────────────────────────────────────
import yaml
from pydantic import BaseModel

# ─── Local ───────────────────────────────────────────────────────────
from core.config import get_settings

if TYPE_CHECKING:
    from core.kg.etl_utils import Neo4jConfig

# ─── Module-level constants ──────────────────────────────────────────
LOGGER_NAME = "core.<module_name>"
DEFAULT_TIMEOUT = 30

# ─── Module logger (MANDATORY) ───────────────────────────────────────
logger = logging.getLogger(__name__)


# ─── Public API ──────────────────────────────────────────────────────
def public_function() -> None:
    """Public function with Google-style docstring."""
    ...


class PublicClass:
    """Public class — first letter capitalized."""
    ...


# ─── Private API ─────────────────────────────────────────────────────
def _private_helper() -> None:
    """Private function — leading underscore."""
    ...


__all__ = [
    "LOGGER_NAME",
    "DEFAULT_TIMEOUT",
    "public_function",
    "PublicClass",
]
```

### 2.2 Package Directory Layout

```
core/<package_name>/
├── __init__.py           # ONLY re-exports + __all__ (alphabetically sorted)
├── constants.py          # Module-level constants (if any)
├── types.py              # Pydantic models, TypedDict, dataclasses (if any)
├── <name>.py             # Main implementation
└── <name>_test.py        # Inline tests (rare — prefer tests/unit/)
```

### 2.3 When to Split Files

Split a file when **any** of these are true:
- File exceeds 500 lines
- File has more than 3 distinct concerns (e.g., parsing, validating, executing)
- Multiple unrelated classes with no shared state
- Multiple import groups that don't co-occur

**Do not split** a file just because it's long if the concerns are tightly coupled.

---

## 3. Function Signatures

### 3.1 Standard Patterns

```python
# Configuration loader
def load_case_config(case_name: str) -> CaseConfig:
    ...

# ETL function
def load_neo4j_nodes(csv_path: Path, neo4j_config: Neo4jConfig) -> int:
    ...

# LangGraph node
def n04_context_assessment(state: State) -> dict:
    ...

# Validator
def validate_node_count(count: int, expected: int) -> None:
    ...

# Helper
def _safe_float(value: str | int | float) -> float:
    ...
```

### 3.2 Argument Order (Conventional)

```python
def function(
    required_positional: str,           # 1. Required positional
    optional_keyword: int = 10,         # 2. Optional keyword
    *,                                  # 3. Keyword-only separator (when ≥3 args)
    kw_only_required: bool,             # 4. Required keyword-only
    kw_only_optional: str | None = None, # 5. Optional keyword-only
) -> ReturnType:
    ...
```

### 3.3 Default Values

- **Mutable defaults:** NEVER use `[]`, `{}`, `set()`. Use `None` and check inside:
  ```python
  def func(items: list | None = None) -> list:
      if items is None:
          items = []
      ...
  ```

- **Empty collections:** `None` is preferred over empty containers as default.

- **Sentinels:** Use `class _MISSING: pass` for "argument not provided" markers when `None` is a valid value.

### 3.4 Return Types

Always annotate return types. Use these patterns:

| Pattern | When |
|---------|------|
| `-> None` | Function returns nothing |
| `-> T` | Function always returns T |
| `-> T \| None` | Function may return None on failure |
| `-> tuple[T, U]` | Function returns fixed-shape tuple |
| `-> dict[str, T]` | Function returns homogeneous dict |
| `-> list[T]` | Function returns list (avoid `List[T]`) |
| `-> Callable[[X], Y]` | Function returns callback |
| `-> Iterator[T]` | Function is a generator |

---

## 4. Type Hints

### 4.1 Modern Syntax (Python 3.10+)

```python
# ✅ CORRECT
def func(x: int | None) -> str | None:
    items: list[str] = []
    config: dict[str, int] = {}
    result: tuple[int, str] = (1, "a")

# ❌ WRONG (do not use in new code)
from typing import Optional, List, Dict, Tuple, Union
def func(x: Optional[int]) -> Optional[str]: ...
items: List[str] = []
config: Dict[str, int] = {}
```

### 4.2 Generic Types

```python
# ✅ CORRECT
T = TypeVar("T")
def first(items: list[T]) -> T | None:
    return items[0] if items else None

# ❌ AVOID (use specific types)
def first(items: list) -> object:
    return items[0] if items else None
```

### 4.3 `Any` Usage

**Avoid `Any`.** When truly needed, add a comment explaining why:

```python
# Acceptable: third-party library without type hints
def parse_response(response: "Any") -> dict:  # type: ignore[name-defined]
    ...
```

**Replace `Any` with:**
- `object` for "any value, no operations"
- `Unknown` from `typing_extensions` for "we don't know yet"
- Concrete types when possible

---

## 5. Error Handling

### 5.1 The Iron Rule

**NEVER use bare `except:` or `except Exception: pass`.**

This is enforced by `ruff check --select SIM105,SIM110`.

### 5.2 Standard Pattern

```python
import logging
logger = logging.getLogger(__name__)


def risky_function(input: str) -> dict:
    """Function that may fail."""
    try:
        result = process(input)
        return {"ok": True, "data": result}
    except SpecificError as e:
        # Expected error — log at debug/warning level
        logger.debug("Processing failed for %s: %s", input, e)
        return {"ok": False, "error": str(e)}
    except Exception:
        # Unexpected — log full traceback
        logger.exception("Unexpected error processing %s", input)
        raise
```

### 5.3 Custom Exception Hierarchy

```python
# core/exceptions.py
class AegisError(Exception):
    """Base exception for all AEGIS-KG errors."""

class Neo4jConnectionError(AegisError):
    """Raised when Neo4j is unreachable."""

class LLMProviderError(AegisError):
    """Raised when LLM call fails after retries."""

class ConfigurationError(AegisError):
    """Raised when case.yaml or environment is misconfigured."""
```

### 5.4 Context Managers

```python
# ✅ CORRECT
with open("file.txt") as f:
    content = f.read()

# ✅ CORRECT (custom)
@contextmanager
def neo4j_session(uri: str, auth: tuple):
    driver = GraphDatabase.driver(uri, auth=auth)
    try:
        yield driver.session()
    finally:
        driver.close()

# ❌ WRONG
f = open("file.txt")
content = f.read()
f.close()  # skipped on exception
```

### 5.5 Resource Cleanup

Always use `try/finally` for resources that don't support `with`:

```python
driver = GraphDatabase.driver(uri, auth=auth)
try:
    with driver.session() as session:
        result = session.run(query)
        return result.single()
finally:
    driver.close()
```

---

## 6. Logging

### 6.1 Logger Setup (MANDATORY in every module)

```python
import logging

logger = logging.getLogger(__name__)
```

**Do not** use `logging.getLogger("core.module_name")` — use `__name__`.

### 6.2 Log Levels

| Level | When to Use | Example |
|-------|-------------|---------|
| `DEBUG` | Detailed diagnostic info, verbose fallback chains | JSON parse retry attempts |
| `INFO` | Confirmation that things work as expected | "Loaded 150 Regulation nodes" |
| `WARNING` | Something unexpected but recoverable | "Connection retry 2/3" |
| `ERROR` | A function failed to do its job | "Failed to load config, using defaults" |
| `EXCEPTION` | Use `logger.exception()` to include traceback | Always with `try/except` |

### 6.3 Log Message Style

```python
# ✅ CORRECT (lazy formatting, structured)
logger.info("Loaded %d nodes from %s", count, filename)
logger.debug("Parse attempt %d failed: %s", attempt, error)

# ❌ WRONG (f-string forces evaluation even if level disabled)
logger.info(f"Loaded {count} nodes from {filename}")
```

---

## 7. Docstrings (Google Style)

### 7.1 Function Template

```python
def function(arg1: str, arg2: int = 10) -> bool:
    """Short one-line summary.
    
    Longer description if needed, spanning multiple lines.
    Use blank line before Args.
    
    Args:
        arg1: Description of arg1.
        arg2: Description of arg2. Defaults to 10.
    
    Returns:
        True if successful, False otherwise.
    
    Raises:
        ValueError: If arg1 is empty.
        ConnectionError: If backend is unreachable.
    
    Example:
        >>> function("test")
        True
    """
```

### 7.2 Class Template

```python
class MyClass:
    """Short summary of the class.
    
    Longer description spanning multiple lines.
    
    Attributes:
        attr1: Description of attr1.
        attr2: Description of attr2.
    """
    
    def __init__(self, attr1: str) -> None:
        """Initialize the class.
        
        Args:
            attr1: Description of attr1.
        """
        self.attr1 = attr1
```

### 7.3 When to Skip Docstrings

- One-line methods that are self-evident:
  ```python
  @property
  def name(self) -> str:
      return self._name
  ```
- Trivial private helpers (`_` prefix)
- Test functions (use descriptive test names instead)

---

## 8. Configuration & Secrets

### 8.1 Environment Variables

- **Read via** `core.config.get_settings()` or `core.config.defaults`
- **Never** `os.getenv("NEO4J_PASSWORD", "default")` in business code — that's a default that should be in `defaults.py`
- **Never** hardcode passwords, URLs, or model names in `core/` or `cases/`

### 8.2 Ports (CRITICAL — AEGIS-KG Specific)

| Container | Bolt | HTTP |
|-----------|------|------|
| **AEGIS KG** | **7688** | **7475** |
| D3Fend (NOT ours) | 7687 | 7474 |

**Any 7687 or 7474 in `core/` or `cases/` is a BUG.** Run:
```bash
grep -r "7474\|7687" core/ cases/
```

### 8.3 Case Configuration

- Case-specific config goes in `cases/<case_name>/case.yaml`
- Loaded via `core.config.case_loader.load_case_config(case_name)`
- **Never** hardcode `case` strings — use `case_config.case` property

---

## 9. Neo4j & Cypher

### 9.1 Node Creation (Case Isolation)

```python
# ✅ CORRECT
def create_regulation(tx, reg: dict, case: str) -> None:
    tx.run(
        "CREATE (r:Regulation {"
        "  case: $case,"
        "  id: $id,"
        "  name: $name"
        "})",
        case=case,
        id=reg["id"],
        name=reg["name"],
    )

# ❌ WRONG (no case property = cross-case leakage)
tx.run("CREATE (r:Regulation {id: $id, name: $name})", ...)
```

### 9.2 Executing Cypher

```python
# ✅ CORRECT (use the shared utilities)
from core.kg.etl_utils import exec_cypher_http, get_neo4j_config

neo4j_config = get_neo4j_config()
result = exec_cypher_http("MATCH (n) RETURN count(n)", neo4j_config)

# ❌ WRONG (reimplement HTTP request)
import requests
requests.post("http://localhost:7475/db/data/cypher", json={...})
```

### 9.3 Use `MERGE` for Idempotency

```cypher
// ✅ CORRECT (re-runnable)
MERGE (r:Regulation {case: $case, id: $id})
ON CREATE SET r.name = $name, r.created_at = timestamp()
ON MATCH SET r.name = $name, r.updated_at = timestamp()
RETURN r

// ❌ WRONG (duplicates on re-run)
CREATE (r:Regulation {id: $id, name: $name})
```

---

## 10. Testing

### 10.1 Test File Location

```
tests/
├── unit/
│   ├── test_<module>.py            # For single-file modules
│   ├── <module>/
│   │   └── test_<file>.py          # For multi-file packages
│   └── workflow/
│       └── phase<N>/
│           └── test_<node>.py
├── integration/
│   └── test_<workflow>.py
└── conftest.py                     # Shared fixtures
```

### 10.2 Test Naming

```python
# Pattern: test_<function_being_tested>_<scenario>
def test_load_case_config_with_valid_yaml():
    ...

def test_load_case_config_raises_on_missing_file():
    ...

def test_load_case_config_expands_env_variables():
    ...
```

### 10.3 Test Structure (AAA)

```python
def test_function_behavior():
    # Arrange
    input_data = create_test_input()
    expected = "expected_output"
    
    # Act
    result = function_under_test(input_data)
    
    # Assert
    assert result == expected
```

### 10.4 Fixtures

- Use `conftest.py` for shared fixtures
- Function scope by default; session scope for expensive setup
- Mock external dependencies (Neo4j, Ollama, Langfuse) — never hit real services in unit tests

---

## 11. Imports

### 11.1 Order (enforced by ruff `I` rule)

```python
# 1. Standard library (alphabetical)
import json
import logging
import os
from pathlib import Path

# 2. Third-party (alphabetical)
import yaml
from pydantic import BaseModel
from langchain_core.messages import HumanMessage

# 3. Local (alphabetical, absolute imports only)
from core.config import get_settings
from core.kg.etl_utils import exec_cypher_http
from cases.case1.config import load_config
```

### 11.2 Wildcard Imports

**Avoid `from module import *`.** Use explicit imports or `__all__`:

```python
# ✅ CORRECT
from core.kg import exec_cypher_http, get_neo4j_config

# ❌ WRONG
from core.kg import *
```

**Exception:** Re-export shim files (`__init__.py`) where `__all__` is defined.

### 11.3 Relative vs Absolute

- **Always use absolute imports** for cross-package: `from core.config import get_settings`
- **Relative imports OK within same package** for tightly-coupled modules: `from .types import Neo4jConfig`
- **No relative imports across packages**: `from ..other_pkg import X` is forbidden

---

## 12. Common Pitfalls (AEGIS-KG Specific)

### 12.1 Model Names

- **Default phase1/phase2 model:** `gemma4:e4b` (centralized in `core/config/defaults.py`)
- **Default phase3 model:** `gemma4:e2b` (not yet in defaults — will be added in Phase 5)
- **Judge model:** `minimax` (NOT `MiniMax`, NOT `minimax`)

### 12.2 Case Property

Every Neo4j node MUST have a `case` property for case isolation. Run:
```bash
grep -rn "CREATE (" cases/*/etl/ | grep -v "case:" | head
```
If any line appears, that's a bug.

### 12.3 Port Numbers (reiterated)

| Wrong | Right | Use For |
|-------|-------|---------|
| `7687` | `7688` | Bolt (AEGIS-KG) |
| `7474` | `7475` | HTTP (AEGIS-KG) |
| `11434` | `11434` | Ollama (correct as-is) |

### 12.4 Langfuse

- `LANGFUSE_ENABLED=false` by default (opt-in only)
- Use `core/agent/tracing.py:get_langfuse_callback()` — never instantiate `CallbackHandler` directly

---

## 13. Pre-Commit Checklist

Before committing new code, verify:

- [ ] `make format` — auto-formats code
- [ ] `make lint` — no new ruff errors introduced
- [ ] `make typecheck` — no new mypy errors
- [ ] `make test` — all existing tests still pass
- [ ] `grep -r "7474\|7687" core/ cases/` — returns nothing
- [ ] Module has `logger = logging.getLogger(__name__)` if it has any function logic
- [ ] No bare `except:` or `except ... pass` patterns
- [ ] `Optional[X]` → `X | None` (Python 3.10+ syntax)
- [ ] All public functions have Google-style docstrings
- [ ] `tests/unit/<module>/` has tests for new code

---

## 14. Lessons Learned (Mandatory Reading)

**Before starting work, read `execution/LESSONS.md`** for:
- Model reliability (which model to use for which task)
- Token waste anti-patterns
- Bottleneck files (frequently-read files)
- Edit tool discipline (re-read before edit, byte-for-byte oldString)
- Recurring debugging themes (RAG, Langfuse, Neo4j)

---

## 15. Quick Reference Card

```
NAMING:    files=snake_case.py, classes=PascalCase, functions=snake_case
PORTS:     Bolt=7688, HTTP=7475 (NOT 7687/7474)
MODEL:     gemma4:e4b (default), minimax (judge)
CASE:      Every node needs case property for isolation
LOGGER:    logger = logging.getLogger(__name__)
TYPES:     X | None (not Optional[X])
ERRORS:    logger.debug on specific, logger.exception on unexpected
TESTS:     tests/unit/<module>/test_<file>.py
DOCS:      Google style, public functions only
IMPORT:    stdlib → third-party → local, absolute paths
FUTURE:    from __future__ import annotations (if needed for 3.10 syntax)
```
