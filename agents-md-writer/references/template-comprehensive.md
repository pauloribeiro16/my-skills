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

## 3. Technology Stack

| Layer | Technology | Version/Notes |
|-------|-----------|---------------|
| Runtime | Python | 3.12+ |
| Package Manager | UV | 10-100x faster than pip, replaces pip/poetry |
| API Framework | FastAPI | With Mangum adapter for Lambda |
| AWS Services | Lambda, DynamoDB, S3, API Gateway | Region: us-east-1 |
| IaC | Terraform | 1.5+, S3 backend + DynamoDB locking |
| Database ORM | PynamoDB | For DynamoDB operations |
| Validation | Pydantic | v2 models for API request/response |
| Testing | pytest + moto | moto for AWS service mocking |
| Linting | ruff + mypy | Strict mode |

---

## 4. Project Structure

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

### Security Scanning
```bash
# Code security
bandit -r src/

# Dependency vulnerabilities
pip-audit

# Terraform security
tfsec infrastructure/

# Secret scanning
detect-secrets scan --all-files
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

### PynamoDB Models

```python
from pynamodb.models import Model
from pynamodb.attributes import UnicodeAttribute, NumberAttribute

class UserModel(Model):
    class Meta:
        table_name = 'users'
        region = 'us-east-1'  # CRITICAL: Must match table region

    user_id = UnicodeAttribute(hash_key=True)
    email = UnicodeAttribute()
    created_at = NumberAttribute()
    metadata = UnicodeAttribute(null=True)  # Use null=True for optional
```

- Always define `table_name` and `region` in Meta class
- Use `batch_write()` and `batch_get()` for multiple items
- Mark optional fields with `null=True` (saves storage costs)
- Use conditional operations for concurrency control
- Test with moto: `@mock_dynamodb` decorator

### Pydantic Models

```python
from pydantic import BaseModel, Field, EmailStr

class UserRequest(BaseModel):
    email: EmailStr
    name: str = Field(min_length=1, max_length=100)
    age: int | None = Field(None, gt=0, lt=150)

    class Config:
        json_schema_extra = {
            "example": {"email": "user@example.com", "name": "John Doe", "age": 30}
        }
```

- Use for API request/response validation
- `Field()` for constraints (min_length, gt, lt, regex)
- Type unions (`|`) for optional fields
- `Config.json_schema_extra` auto-generates OpenAPI docs

### FastAPI + Lambda Integration

```python
from fastapi import FastAPI
from mangum import Mangum

app = FastAPI()

@app.get("/users/{user_id}")
async def get_user(user_id: str):
    # Separate handler from business logic
    return UserService().get_user(user_id)

# Lambda handler
handler = Mangum(app)
```

- Keep handlers thin, move logic to service classes
- Initialize AWS clients outside handler for reuse (Lambda container reuse)
- Use async patterns for all I/O operations
- Handle cold starts: provisioned concurrency or SnapStart for critical endpoints
- Environment variables for configuration (never hardcode)

### Terraform

```bash
# Initialize and validate
cd infrastructure
terraform init
terraform validate
terraform fmt -recursive  # Always run before committing

# Plan and apply
terraform plan -var-file=environments/dev.tfvars -out=tfplan
terraform apply tfplan

# Multi-environment (workspaces)
terraform workspace list
terraform workspace select dev
terraform workspace new staging
```

- Store state in S3 with DynamoDB locking
- Use workspaces for environments (dev/staging/prod)
- Tag all resources: environment, project, managed_by, cost_center
- Use modules for reusable components
- Document all variables with description and type
- Enable versioning on S3 state bucket

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

## 8. CI/CD Pipeline

### GitHub Actions Workflows
- **CI**: `.github/workflows/ci.yml` (runs on all PRs)
  - Stages: Lint → Type Check → Unit Tests → Security Scan → Build
  - Must pass before merge allowed
- **Deploy**: `.github/workflows/deploy.yml` (runs on main branch)
  - Stages: Integration Tests → Terraform Plan → Manual Approval → Terraform Apply
  - Separate jobs for staging and production

### Local CI Simulation
```bash
# Run all CI checks locally before pushing
ruff check src/
mypy src/
pytest tests/unit/
bandit -r src/
terraform fmt -check -recursive
```

### Deployment Environments
- **Development**: Auto-deploy on push to `develop` branch
- **Staging**: Auto-deploy on merge to `main` branch
- **Production**: Manual approval required after staging validation

### Merge Requirements
- All CI checks pass (lint, type check, tests, security scan)
- Code coverage ≥80%
- No high or critical severity vulnerabilities
- At least one review approval
- Branch protection rules enforced

### Production Deployment Gates
1. Successful staging deployment and smoke tests
2. Manual approval from team lead
3. Deployment window (weekdays 10am-4pm EST, no Fridays)
4. Rollback plan documented in deployment PR

---

## 9. Deployment

### Local Development
```bash
uv run uvicorn src.main:app --reload  # FastAPI locally
sam local invoke MyFunction -e events/test.json  # Test Lambda locally
sam local start-api  # Local API Gateway
```

### Infrastructure Deployment
```bash
cd infrastructure
terraform workspace select prod
terraform plan -var-file=environments/prod.tfvars
terraform apply -var-file=environments/prod.tfvars
```

### Rollback
```bash
terraform workspace select prod
terraform apply -var-file=environments/prod.tfvars -target=aws_lambda_function.api -var="lambda_version=previous"
```

### Post-Deployment Validation
```bash
# Health check
curl https://api.example.com/health

# CloudWatch logs
aws logs tail /aws/lambda/api --follow

# Smoke tests
pytest tests/smoke/
```

---

## 10. Boundaries

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

## 11. Good Examples

### Patterns to Follow
- `src/services/user.py` — Clean service layer with type hints
- `src/api/routes/users.py` — Thin routes, delegate to services
- `tests/unit/test_services.py` — Proper mocking and assertions

### Anti-patterns to Avoid
- `src/old/legacy_handler.py` — Synchronous patterns (deprecated)
- `src/utils/raw_sql.py` — Direct SQL without parameterization
- Hardcoded anything anywhere

---

## 12. Troubleshooting

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

## 13. Additional Resources

- [Link to API docs]
- [Link to architecture docs]
- [Link to team wiki]

---

**Last Updated:** YYYY-MM-DD
