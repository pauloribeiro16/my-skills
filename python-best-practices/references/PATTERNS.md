# Python Design Patterns

Common patterns for writing clean, maintainable Python code.

## Data Models

### Dataclasses (stdlib, Python 3.7+)

```python
from dataclasses import dataclass, field
from pathlib import Path

@dataclass(frozen=True)
class Config:
    database_url: str
    api_key: str
    timeout: int = 30
    debug: bool = False
    allowed_hosts: list[str] = field(default_factory=list)

@dataclass
class User:
    id: int
    name: str
    email: str
    is_active: bool = True

    def activate(self) -> None:
        self.is_active = True
```

### Pydantic v2 (for validation + serialization)

```python
from pydantic import BaseModel, EmailStr, Field
from datetime import datetime

class UserCreate(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    email: EmailStr
    age: int = Field(ge=0, le=150)

    model_config = {"extra": "forbid"}

class UserResponse(BaseModel):
    id: int
    name: str
    email: str
    created_at: datetime

    model_config = {"from_attributes": True}
```

### TypedDict (for structured dicts)

```python
from typing import TypedDict

class Movie(TypedDict):
    title: str
    year: int
    rating: float
```

## Async/Await

### Basic Async Functions

```python
import asyncio
import httpx

async def fetch_user(user_id: int) -> dict:
    async with httpx.AsyncClient() as client:
        response = await client.get(f"https://api.example.com/users/{user_id}")
        response.raise_for_status()
        return response.json()

async def main() -> None:
    user = await fetch_user(42)
    print(user)

asyncio.run(main())
```

### Structured Concurrency with Task Groups

```python
async def fetch_all_users(user_ids: list[int]) -> list[dict]:
    async with asyncio.TaskGroup() as tg:
        tasks = [tg.create_task(fetch_user(uid)) for uid in user_ids]

    return [task.result() for task in tasks]
```

### Async Context Managers

```python
from contextlib import asynccontextmanager

@asynccontextmanager
async def database_session(url: str):
    conn = await connect_to_db(url)
    try:
        yield conn
    finally:
        await conn.close()

async def query_users() -> list[dict]:
    async with database_session("postgresql://localhost/db") as db:
        return await db.fetch("SELECT * FROM users")
```

## Error Handling

### Custom Exception Hierarchy

```python
class DomainError(Exception):
    """Base exception for all domain errors."""
    pass

class UserNotFoundError(DomainError):
    def __init__(self, user_id: int):
        self.user_id = user_id
        super().__init__(f"User {user_id} not found")

class ValidationError(DomainError):
    def __init__(self, field: str, message: str):
        self.field = field
        super().__init__(f"Validation error on {field}: {message}")
```

### Structured Logging

```python
import logging
from pathlib import Path

logger = logging.getLogger(__name__)

def process_file(filepath: Path) -> dict:
    try:
        content = filepath.read_text()
        return parse_content(content)
    except FileNotFoundError:
        logger.error("File not found: %s", filepath)
        raise
    except ValueError as e:
        logger.error("Invalid content in %s: %s", filepath, e)
        raise
    except Exception:
        logger.exception("Unexpected error processing %s", filepath)
        raise
```

## CLI Applications

```python
import argparse
from pathlib import Path

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Process data files")
    parser.add_argument("input", type=Path, help="Input file path")
    parser.add_argument("-o", "--output", type=Path, help="Output file path")
    parser.add_argument("-v", "--verbose", action="store_true")
    return parser.parse_args()

def main() -> None:
    args = parse_args()
    # ...

if __name__ == "__main__":
    main()
```

## Configuration Management

```python
from dataclasses import dataclass
from pathlib import Path
import tomllib

def load_config(config_path: Path) -> Config:
    with config_path.open("rb") as f:
        data = tomllib.load(f)
    return Config(**data)
```
