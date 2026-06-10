# Python Testing

Complete reference for writing and maintaining Python tests.

## pytest Basics

```python
import pytest
from myproject import calculate_unit_price

def test_basic_calculation():
    result = calculate_unit_price(100.0, 10, 0.0)
    assert result == 10.0

def test_with_tax():
    result = calculate_unit_price(100.0, 10, 0.2)
    assert result == 12.0

def test_zero_quantity_raises_error():
    with pytest.raises(ZeroDivisionError):
        calculate_unit_price(100.0, 0, 0.1)
```

### Parametrized Tests

```python
@pytest.mark.parametrize("total,qty,tax,expected", [
    (100, 10, 0.0, 10.0),
    (100, 10, 0.1, 11.0),
    (50, 5, 0.2, 12.0),
    (0, 10, 0.0, 0.0),
])
def test_multiple_scenarios(total, qty, tax, expected):
    assert calculate_unit_price(total, qty, tax) == pytest.approx(expected)
```

### Fixtures

```python
import pytest
from pathlib import Path
from tempfile import TemporaryDirectory

@pytest.fixture
def temp_dir():
    with TemporaryDirectory() as tmp:
        yield Path(tmp)

@pytest.fixture
def config_file(temp_dir):
    path = temp_dir / "config.toml"
    path.write_text("""
[database]
url = "sqlite:///test.db"
    """)
    return path

def test_load_config(config_file):
    config = load_config(config_file)
    assert config.database_url == "sqlite:///test.db"
```

### Markers

```python
@pytest.mark.slow
def test_heavy_computation():
    ...

@pytest.mark.skip(reason="not implemented yet")
def test_future_feature():
    ...

@pytest.mark.xfail(reason="known bug #42")
def test_known_issue():
    ...
```

## Async Testing

### pytest-asyncio

```python
import pytest

@pytest.mark.asyncio
async def test_async_fetch():
    user = await fetch_user(42)
    assert user["id"] == 42

@pytest.mark.asyncio
async def test_async_fetch_not_found():
    with pytest.raises(UserNotFoundError):
        await fetch_user(99999)
```

### Async Fixtures

```python
import pytest_asyncio

@pytest_asyncio.fixture
async def db_connection():
    conn = await connect_to_db("sqlite:///:memory:")
    yield conn
    await conn.close()

@pytest.mark.asyncio
async def test_query(db_connection):
    users = await db_connection.fetch("SELECT * FROM users")
    assert len(users) == 0
```

### IsolatedAsyncioTestCase (stdlib)

```python
import unittest

class TestAsyncStuff(unittest.IsolatedAsyncioTestCase):
    async def asyncSetUp(self):
        self.client = await create_test_client()

    async def test_fetch_user(self):
        user = await self.client.get_user(42)
        self.assertEqual(user["id"], 42)

    async def asyncTearDown(self):
        await self.client.close()
```

## Mocking

### Basic Mocking

```python
from unittest.mock import AsyncMock, Mock, patch

def test_get_user(mocker):
    mock_response = {"id": 42, "name": "Alice"}
    mocker.patch("myproject.api_client.get_user", return_value=mock_response)

    result = get_user_service(42)
    assert result["name"] == "Alice"
```

### AsyncMock

```python
@pytest.mark.asyncio
async def test_async_service(mocker):
    mock = AsyncMock(return_value={"id": 1})
    mocker.patch("myproject.services.fetch_data", mock)

    result = await process_data(1)
    assert result["id"] == 1
    mock.assert_called_once_with(1)
```

### Patch with Context Manager

```python
def test_file_processing():
    with patch("pathlib.Path.read_text") as mock_read:
        mock_read.return_value = "name,age\nAlice,30"
        data = parse_csv("fake.csv")
        assert data[0]["name"] == "Alice"
```

## Property-Based Testing (Hypothesis)

```python
from hypothesis import given, strategies as st

@given(st.lists(st.integers(min_value=1)))
def test_sorting_never_loses_elements(items):
    sorted_items = sorted(items)
    assert len(sorted_items) == len(items)
    assert all(x in sorted_items for x in items)

@given(st.text(min_size=1))
def test_uppercase_is_idempotent(s):
    assert s.upper().upper() == s.upper()
```

### Custom Strategies

```python
from hypothesis import strategies as st

UserStrategy = st.builds(
    dict,
    id=st.integers(min_value=1),
    name=st.text(min_size=1, max_size=50),
    email=st.emails(),
    age=st.integers(min_value=0, max_value=150),
)

@given(user=UserStrategy)
def test_user_validation(user):
    result = validate_user(user)
    assert result["id"] > 0
```

## Mutation Testing

Mutation testing checks test quality by introducing bugs and seeing if tests catch them.

```bash
# Install
uv add --dev mutmut

# Run mutation tests
mutmut run --paths-to-mutate src/

# Show results
mutmut results

# View surviving mutations
mutmut show 1
```

Aim for >80% mutation score. Surviving mutations often reveal missing edge cases.

## Running Tests

```bash
# All tests
pytest

# Single file
pytest tests/test_pricing.py

# Single test
pytest tests/test_pricing.py::test_basic_calculation

# With coverage
pytest --cov=src/ --cov-report=term-missing

# Parallel
pytest -n auto

# Stop on first failure
pytest -x
```
