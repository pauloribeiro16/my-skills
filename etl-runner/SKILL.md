---
name: etl-runner
description: "Use when running ETL scripts to load data into a database or knowledge graph. Ensures correct connection settings, proper data paths, tenant isolation, and sequential phase execution."
---

# ETL Runner Skill

Runs ETL scripts correctly to populate databases or knowledge graphs.

## When to Activate

- Running any ETL script
- Loading data into a database
- Checking ETL results
- Troubleshooting missing data

## Port & Protocol Rule

Always verify the correct protocol and port for your target service.

| Protocol | Port | Use |
|----------|------|-----|
| **HTTP/REST** | Configurable | ETL scripts / data loading APIs |
| **Bolt/Native** | Configurable | Direct DB access (not for ETL) |

Ports should be read from environment variables, never hardcoded.

## Command Templates

### Standalone ETL Script
```bash
PYTHONPATH=. python [path]/etl/[script_name].py
```

### Via Make (if configured)
```bash
make etl STAGE=[name] DATA_PATH=[path]
```

## ETL Phases

ETL should run in sequential phases. Each phase builds on the previous one.

| Phase | What it loads | Order |
|-------|---------------|-------|
| Phase 1 | Core entities, base definitions | First |
| Phase 2 | Relations, mappings, cross-references | Second |
| Phase 3 | Advanced structures, derived data | Third |

**Always run Phase 1 before Phase 2 before Phase 3**

Adjust phase names and counts per your project.

## ETL Script Structure

Each ETL script should:
1. Read data files from a configurable data directory
2. Connect via configurable endpoints (from env vars)
3. Set a `tenant` or `dataset` property on all records for isolation
4. Print progress with ✓ and ✗ markers

### Expected Script Pattern
```python
from pathlib import Path
import os

def get_connection():
    uri = os.getenv("DB_HTTP_URL", "http://localhost:7474")
    # ... connect using env-driven config

def run(config):
    """Main entry point"""
    data_dir = Path(__file__).parent.parent / config.get("data_dir", "data") / "phase1"
    # ... load data files, create records, set tenant property
    print("✓ Loaded N records")
```

## Verification Steps

### Step 1 — Run ETL
```bash
PYTHONPATH=. python [script_path]
```

### Step 2 — Verify Data Loaded
```bash
# Check record counts per phase
python -c "
from db_driver import connect
import os
conn = connect(uri=os.getenv('DB_URI'), ...)
count = conn.query('MATCH (n:Entity) RETURN count(n)').single()[0]
print(f'Entities: {count}')
conn.close()
"
```

### Step 3 — Verify Tenant/Dataset Isolation

All records should have a `tenant` or `dataset` property set:
```sql
-- Should return ONLY current dataset records
SELECT count(*) FROM records WHERE tenant = 'current'
```

## Common Bug Patterns

### ❌ WRONG — Hardcoded connection
```python
uri = "http://localhost:7474"  # WRONG
```

### ✅ CORRECT — From environment
```python
import os
uri = os.getenv("DB_HTTP_URL", "http://localhost:7474")
```

### ❌ WRONG — No tenant isolation
```python
# Creates records without dataset isolation
CREATE (r:Record {name: "Item"})
```

### ✅ CORRECT — With tenant property
```python
CREATE (r:Record {name: "Item", tenant: "current_dataset"})
```

## ETL Error Handling

| Error | Cause | Fix |
|-------|-------|-----|
| Connection refused | Wrong port or service not running | Check endpoint, check service status |
| File not found | Wrong data path | Check data directory exists |
| Duplicate records | Running ETL twice | Check first, then create |
| Missing relationships | Wrong order | Run phases sequentially |

## Output Format

```
## ETL Results

**Script:** [script_name]
**Phase:** [1|2|3]
**Dataset:** [tenant/dataset name]

### Execution
✓ Loaded 150 Entity records
✓ Loaded 23 Category records
✓ Loaded 89 Relation records
✗ Failed: Constraint error on record:45

### Verification
Entities: 150
Categories: 23
Relations: 89

**Verdict:** PARTIAL (1 error)
**Next step:** Fix record:45 constraint
```

## Safety Rules

- Run phases in order (Phase 1 before Phase 2)
- Check for existing data before CREATE
- Use MERGE instead of CREATE when appropriate
- Always set tenant/dataset property for isolation
- Read connection parameters from environment, never hardcode
