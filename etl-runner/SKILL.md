---
name: etl-runner
description: "Use when running ETL scripts to load data into Neo4j. Ensures correct port (7475 HTTP), proper CSV paths, case property setting, and sequential phase execution."
---

# ETL Runner Skill

Runs ETL scripts correctly to populate Neo4j knowledge graphs.

## When to Activate

- Running any ETL script
- Loading data into Neo4j
- Checking ETL results
- Troubleshooting missing data

## ETL Port Rule (CRITICAL)

ETL uses **HTTP** protocol, not Bolt.

| Protocol | Port | Use |
|----------|------|-----|
| **HTTP** | **7475** | ETL scripts |
| Bolt | 7688 | Direct DB access (not for ETL) |

## Command Templates

### Standalone ETL Script (preferred)
```bash
PYTHONPATH=. python [case_path]/etl/01_load_regulation.py
```

### Via Generic Runner
```bash
PYTHONPATH=. python -c "
from core.kg.etl_base import run_etl
run_etl('[case_path]/etl')
"
```

### Via Make
```bash
make etl CASE=[case_name] PHASE=[1|2|3]
```

## ETL Phases

| Phase | What it loads | Order |
|-------|---------------|-------|
| Phase 1 | Regulations, domains, subdomains, articles, clauses | First |
| Phase 2 | Obligations, goals, clause-subdomain mappings | Second |
| Phase 3 | Strategic tensions, complementarity, timelines | Third |

**Always run Phase 1 before Phase 2 before Phase 3**

## ETL Script Structure

Each ETL script should:
1. Read CSV files from `data/phaseN/` directory
2. Connect via HTTP (port 7475)
3. Set `case` property on all nodes for isolation
4. Print progress with ✓ and ✗ markers

### Expected Script Pattern
```python
from pathlib import Path
from neo4j import GraphDatabase

def exec_cypher(query, params=None):
    """Execute via HTTP API"""
    import os
    uri = os.getenv("NEO4J_HTTP_URL", "http://localhost:7475")
    # ... execute query

def run(neo4j_config):
    """Main entry point"""
    csv_dir = Path(__file__).parent.parent / "data" / "phase1"
    # ... load CSVs, create nodes, set case property
    print("✓ Loaded N nodes")
```

## Verification Steps

### Step 1 — Run ETL
```bash
PYTHONPATH=. python [script_path]
```

### Step 2 — Verify Data Loaded
```bash
# Check node counts per phase
python -c "
from neo4j import GraphDatabase
import os
d = GraphDatabase.driver('bolt://localhost:7688', auth=('neo4j', os.getenv('NEO4J_PASSWORD', '')))
s = d.session()
# Check with case filter
count = s.run('MATCH (n:Regulation) WHERE n.case = \"case1\" RETURN count(n)').single()[0]
print(f'Regulation nodes: {count}')
s.close()
"
```

### Step 3 — Verify Case Property

All nodes must have `case` property set:
```cypher
// Should return ONLY current case nodes
MATCH (n) WHERE n.case = "case1" RETURN count(n)
```

## Common Bug Patterns

### ❌ WRONG — Hardcoded port
```python
uri = "http://localhost:7474"  # WRONG
```

### ✅ CORRECT — From environment
```python
import os
uri = os.getenv("NEO4J_HTTP_URL", "http://localhost:7475")
```

### ❌ WRONG — No case property
```python
# Creates nodes without case isolation
CREATE (r:Regulation {name: "GDPR"})
```

### ✅ CORRECT — With case property
```python
CREATE (r:Regulation {name: "GDPR", case: "case1"})
```

## ETL Error Handling

| Error | Cause | Fix |
|-------|-------|-----|
| Connection refused | Wrong port or Neo4j not running | Check 7475, check docker |
| File not found | Wrong CSV path | Check data/phaseN/ exists |
| Duplicate nodes | Running ETL twice | MATCH first, then CREATE |
| Missing relationships | Wrong order | Run phases sequentially |

## Output Format

```
## ETL Results

**Script:** [script_name]
**Phase:** [1|2|3]
**Case:** [case_name]

### Execution
✓ Loaded 150 Regulation nodes
✓ Loaded 23 Domain nodes
✓ Loaded 89 Subdomain nodes
✗ Failed: Constraint error on Article:45

### Verification
Regulation nodes: 150
Domain nodes: 23
Subdomain nodes: 89

**Verdict:** PARTIAL (1 error)
**Next step:** Fix Article:45 constraint
```

## Safety Rules

- Run Phase 1 before Phase 2
- Check for existing data before CREATE
- Use MERGE instead of CREATE when appropriate
- Always set `case` property for isolation
