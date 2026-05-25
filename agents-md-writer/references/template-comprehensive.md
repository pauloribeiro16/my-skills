# AGENTS.md — [Project Name]

**Purpose:** Onboarding for AI coding agents. Structured technical guidance.
**Standard:** AGENTS.md best practices + [team standards]

---

## 1. Architecture

```
[Diagram or description of system architecture]
```

| Component | Tech | Purpose |
|-----------|------|---------|
| API | FastAPI | REST endpoints |
| DB | PostgreSQL | Primary datastore |
| Cache | Redis | Session/cache |

---

## 2. Environment

### Prerequisites
- Python 3.12+
- Docker (for services)
- [other tools]

### Setup
```bash
# Clone and setup
git clone [repo]
cd [project]
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Configure
cp .env.example .env
# Edit .env with your values

# Verify
python --version
pytest --version
```

### Environment Variables
| Variable | Source | Description |
|----------|--------|-------------|
| `DATABASE_URL` | .env | PostgreSQL connection |
| `REDIS_URL` | .env | Redis connection |
| `SECRET_KEY` | .env | App secret (generate with `openssl`) |

---

## 3. Project Structure

```
src/
  api/           # FastAPI routes and middleware
  models/        # SQLAlchemy models
  services/      # Business logic
  utils/         # Shared utilities
tests/
  unit/          # Unit tests (fast, no DB)
  integration/   # Integration tests (requires DB)
  conftest.py    # Shared fixtures
docs/            # Documentation
scripts/         # Utility scripts
```

---

## 4. Commands

### File-scoped (preferred — fast feedback)
```bash
# Test single file
pytest tests/unit/test_models.py
pytest tests/unit/test_models.py::test_user_creation

# Check single file
ruff check src/models/user.py
mypy src/models/user.py

# Format single file
ruff format src/models/user.py
```

### Full suite (when explicitly requested)
```bash
# All tests with coverage
pytest --cov=src --cov-report=html --cov-report=term

# All linting
ruff check .
mypy src/

# Full CI simulation
./scripts/ci-check.sh
```

### Database
```bash
# Migrations
alembic revision --autogenerate -m "description"
alembic upgrade head
alembic downgrade -1

# Seed data
python scripts/seed.py
```

### Docker
```bash
# Start services
docker-compose up -d postgres redis

# Stop services
docker-compose down
```

---

## 5. Code Style

### Naming
- **Functions:** snake_case (`get_user_by_id`)
- **Classes:** PascalCase (`UserService`)
- **Constants:** UPPER_SNAKE_CASE (`MAX_RETRY_COUNT`)
- **Private:** leading underscore (`_internal_helper`)

### Type Hints
- Use everywhere (mypy strict mode)
- Prefer `str | None` over `Optional[str]`
- Use `TypedDict` for dict structures

### Examples
```python
# Good — type hints, docstring, error handling
from typing import TypedDict

class UserDict(TypedDict):
    id: str
    email: str

async def get_user(user_id: str) -> UserDict:
    """Fetch user by ID.
    
    Args:
        user_id: UUID string
        
    Returns:
        User dictionary
        
    Raises:
        ValueError: If user_id is empty
        NotFoundError: If user doesn't exist
    """
    if not user_id:
        raise ValueError("user_id is required")
    
    user = await user_repo.get(user_id)
    if not user:
        raise NotFoundError(f"User {user_id} not found")
    
    return {"id": user.id, "email": user.email}

# Bad — no types, no docs, poor error handling
def get(x):
    return db.query("SELECT * FROM users WHERE id = " + x)
```

---

## 6. Testing

### Framework
- **pytest** with asyncio support
- **pytest-cov** for coverage
- **pytest-asyncio** for async tests

### Structure
```
tests/
  unit/              # Fast, isolated, no DB
  integration/       # Requires DB and services
  e2e/               # Full flow tests
```

### Running Tests
```bash
# Unit only (fast)
pytest tests/unit/

# Integration (slower, needs services)
pytest tests/integration/

# With coverage
pytest --cov=src --cov-report=html
open htmlcov/index.html
```

### Requirements
- 80%+ coverage for new code
- All new features require tests
- Integration tests for API endpoints
- Use factories (not fixtures) for test data

### Example
```python
# tests/unit/test_services.py
import pytest
from src.services.user import UserService

@pytest.fixture
def user_service():
    return UserService(mock_repo)

async def test_get_user_found(user_service):
    mock_repo.get.return_value = MockUser(id="1", email="test@example.com")
    
    user = await user_service.get_user("1")
    
    assert user["id"] == "1"
    assert user["email"] == "test@example.com"

async def test_get_user_not_found(user_service):
    mock_repo.get.return_value = None
    
    with pytest.raises(NotFoundError):
        await user_service.get_user("999")
```

---

## 7. Git Workflow

### Branches
- `main` — production-ready
- `feature/*` — new features
- `bugfix/*` — bug fixes
- `hotfix/*` — urgent production fixes

### Commits
- Format: `type(scope): description`
- Types: feat, fix, docs, test, refactor, chore
- Example: `feat(auth): add OAuth2 login`

### Pull Requests
- Title format: `[type] Brief description`
- All CI checks must pass
- At least one review approval
- Keep diffs focused (<400 lines when possible)

### Pre-commit
```bash
# Run before every commit
ruff check .
ruff format .
mypy src/
pytest tests/unit/
```

---

## 8. Boundaries

### Allowed Without Prompting
- Read any source file
- Run linters/formatters on single files
- Run unit tests on specific files
- Edit non-critical documentation

### Require Approval First
- Installing packages (`pip install`, `npm install`)
- Git operations (`git push`, `git commit`)
- Deleting files or directories
- Running full test suites
- Modifying CI/CD configuration
- Database migrations in production

### Never Do
- Commit secrets or credentials
- Edit `.env` files (read `.env.example` instead)
- Modify vendor or generated directories
- Hardcode URLs, credentials, or API keys
- Delete migrations or production data
- Skip tests before committing

---

## 9. Good Examples

### Patterns to Follow
- `src/services/user.py` — Clean service layer with type hints
- `src/api/routes/users.py` — Thin routes, delegate to services
- `tests/unit/test_services.py` — Proper mocking and assertions

### Anti-patterns to Avoid
- `src/old/legacy_handler.py` — Synchronous patterns (deprecated)
- `src/utils/raw_sql.py` — Direct SQL without parameterization
- Hardcoded anything anywhere

---

## 10. Troubleshooting

### Common Issues

**Database connection fails:**
- Check `.env` has correct DATABASE_URL
- Verify Docker services are running: `docker-compose ps`

**Tests fail with import errors:**
- Ensure virtualenv is activated
- Run `pip install -r requirements.txt`

**Migrations out of sync:**
- Run `alembic upgrade head`
- Check `alembic_version` table in DB

---

## 11. Additional Resources

- [Link to API docs]
- [Link to architecture docs]
- [Link to team wiki]

---

**Last Updated:** YYYY-MM-DD