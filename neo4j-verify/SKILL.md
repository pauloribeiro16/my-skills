---
name: neo4j-verify
description: "Use before and after any Neo4j-related work. Verifies correct ports (7688/7475), connection settings, and detects hardcoded port bugs. Critical for data integrity."
---

# Neo4j Verify Skill

Ensures Neo4j connections use correct ports and detects hardcoded port bugs.

## When to Activate

- Before running ETL scripts
- After editing any file with Neo4j connection
- Before validation of ETL results
- When troubleshooting connection issues
- When data seems wrong or missing

## Port Rules (CRITICAL)

| Service | Bolt | HTTP | Purpose |
|---------|------|------|---------|
| **AEGIS KG** | **7688** | **7475** | This project |
| D3Fend (NOT this) | 7687 | 7474 | External |

**Any occurrence of 7687 or 7474 in `core/` or `cases/` = BUG**

## Verification Steps

### Step 1 — Check for Hardcoded Ports

```bash
# Should return NOTHING
grep -r "7474\|7687" core/ cases/
```

If found → FAIL → Fix immediately

### Step 2 — Verify Connection Config

Check that all Neo4j connections read from:
- Environment variables (`.env`), OR
- Case config (`case.yaml`), OR
- Config loader (`config.py`)

Never hardcode:
- `bolt://localhost:7687`
- `http://localhost:7474`
- `'7687'` or `'7474'` as strings

### Step 3 — Test Connection

```bash
# Verify can connect to correct port
python -c "
from neo4j import GraphDatabase
import os
uri = os.getenv('NEO4J_URI', 'http://localhost:7475')
print(f'Testing {uri}')
d = GraphDatabase.driver(uri.replace('http', 'bolt'), auth=('neo4j', os.getenv('NEO4J_PASSWORD', '')))
s = d.session()
result = s.run('RETURN 1 as n').single()
print(f'Connection: {'OK' if result else 'FAIL'}')
s.close()
"
```

### Step 4 — Verify Data Loaded

```bash
# Quick count check for expected data
python -c "
from neo4j import GraphDatabase
import os
d = GraphDatabase.driver('bolt://localhost:7688', auth=('neo4j', os.getenv('NEO4J_PASSWORD', '')))
s = d.session()
# Adapt this query to your case
count = s.run('MATCH (n:Regulation) RETURN count(n) as c').single()[0]
print(f'Regulation nodes: {count}')
s.close()
"
```

## Common Bug Patterns

### ❌ WRONG
```python
driver = GraphDatabase.driver("bolt://localhost:7687", ...)
uri = "http://localhost:7474"
```

### ✅ CORRECT
```python
import os
driver = GraphDatabase.driver(
    os.getenv("NEO4J_URI", "bolt://localhost:7688"),
    auth=(os.getenv("NEO4J_USER", "neo4j"), os.getenv("NEO4J_PASSWORD"))
)
```

## Output Format

```
## Neo4j Verification

### Port Check
grep -r "7474\|7687" core/ cases/ → [PASS/FAIL]
Found: [list files if any]

### Connection Test
URI: [what was used]
Result: [OK/FAIL]

### Data Check
Regulation nodes: [count]
[Other relevant counts]

**Verdict:** [PASS/FAIL]
```

## If FAIL

1. Identify files with wrong ports
2. Fix to use environment variables
3. Re-run verification
4. Report what was fixed
