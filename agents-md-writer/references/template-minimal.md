# AGENTS.md — [Project Name]

**Purpose:** Onboarding for AI coding agents.
**Standard:** AGENTS.md best practices

---

## 1. Environment

```bash
# Setup
python -m venv .venv
source .venv/bin/activate  # Linux/Mac
pip install -r requirements.txt

# Verify
python --version
```

---

## 2. Project Structure

```
src/           # Source code
tests/         # Tests
docs/          # Documentation
```

---

## 3. Commands

### File-scoped (preferred)
```bash
pytest tests/test_file.py
ruff check src/file.py
mypy src/file.py
```

### Full suite
```bash
pytest --cov=src
ruff check .
```

---

## 4. Code Style

- **Python:** PEP 8, type hints
- **Naming:** snake_case functions, PascalCase classes
- **Imports:** stdlib, third-party, local

```python
# Good
def fetch_user(user_id: str) -> User:
    if not user_id:
        raise ValueError("ID required")
    return api.get(f"/users/{user_id}")

# Bad
def get(x):
    return api.get("/users/" + x)
```

---

## 5. Testing

- **Framework:** pytest
- **Coverage:** 80%+ for new code
- **Run:** `pytest tests/`

---

## 6. Boundaries

- **Always:** Run tests before commits, follow style guide
- **Ask first:** Adding dependencies, modifying CI/CD
- **Never:** Commit secrets, edit vendor directories, hardcode credentials

---

**Last Updated:** YYYY-MM-DD