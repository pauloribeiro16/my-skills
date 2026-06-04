---
name: service-verify
description: "Use before and after any service-dependent work. Verifies correct endpoint/port configuration, detects hardcoded connection strings, and ensures env-based config. Critical for data integrity."
---

# Service Verify Skill

Ensures service connections use correct endpoints and detects hardcoded connection bugs.

## When to Activate

- Before running data loading scripts
- After editing any file with service connections
- Before validation of results
- When troubleshooting connection issues
- When data seems wrong or missing

## Endpoint Rules (CRITICAL)

Each service has a specific endpoint configuration. Verify the correct ports/protocols for your project.

| Service | Expected Endpoint | Environment Variable | Purpose |
|---------|------------------|---------------------|---------|
| [Main DB] | [endpoint] | `[DB_URI]` | This project |
| [External] | [endpoint] | `[EXT_URI]` | External reference (if applicable) |

**Any hardcoded endpoint strings in source/config files = BUG**

## Verification Steps

### Step 1 — Check for Hardcoded Endpoints

```bash
# Should return NOTHING — adapt patterns to your project's known bad ports/uris
grep -r "[known_bad_pattern]" [source_dirs]/
```

If found → FAIL → Fix immediately

### Step 2 — Verify Connection Config

Check that all service connections read from:
- Environment variables (`.env`), OR
- Project config files (e.g., `config.yaml`), OR
- A config loader module

Never hardcode:
- `protocol://localhost:port`
- Specific port numbers as literal strings
- Connection credentials in source code

### Step 3 — Test Connection

```bash
# Verify can connect to correct endpoint
python -c "
import os
uri = os.getenv('SERVICE_URI', 'protocol://localhost:default_port')
print(f'Testing {uri}')
# Adapt connection logic to your service type
result = connect(uri, ...)
print(f'Connection: {'OK' if result else 'FAIL'}')
"
```

### Step 4 — Verify Data Loaded (if applicable)

```bash
# Quick count check for expected data
python -c "
import os
conn = connect(os.getenv('SERVICE_URI'))
count = conn.query('SELECT count(*) FROM records').single()[0]
print(f'Records: {count}')
conn.close()
"
```

## Common Bug Patterns

### ❌ WRONG
```python
driver = Driver("protocol://localhost:port", ...)
uri = "http://localhost:custom_port"
```

### ✅ CORRECT
```python
import os
driver = Driver(
    os.getenv("SERVICE_URI", "protocol://localhost:default_port"),
    auth=(os.getenv("SERVICE_USER", "user"), os.getenv("SERVICE_PASSWORD"))
)
```

## Output Format

```
## Service Verification

### Endpoint Check
grep -r "[known_bad_pattern]" [source_dirs]/ → [PASS/FAIL]
Found: [list files if any]

### Connection Test
URI: [what was used]
Result: [OK/FAIL]

### Data Check (if applicable)
Records: [count]
[Other relevant counts]

**Verdict:** [PASS/FAIL]
```

## If FAIL

1. Identify files with hardcoded endpoints
2. Fix to use environment variables
3. Re-run verification
4. Report what was fixed
