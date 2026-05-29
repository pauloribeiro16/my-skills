# Validation Commands Reference

## The 4-Tier System

| Tier | Tests | Required for |
|------|-------|--------------|
| **T1 Syntax** | `python -m py_compile` | NICE criteria |
| **T2 Import/Runtime** | `python -c "from module import X"` | SHOULD criteria |
| **T3 Behavioral** | `python -c "assert function_behavior"` | MUST criteria |
| **T4 Integration** | `python -c "graph.invoke(mock_state)"` | Complex features |

## Validation Tier Rules

1. **MUST criterion** → Tier 3 minimum (behavioral)
2. **SHOULD criterion** → Tier 2 minimum (import/runtime)
3. **NICE criterion** → Tier 1 acceptable (syntax only)
4. If a criterion cannot be tested with a command → **rewrite the criterion** until it can

## Examples

| Criterion | Bad Validation ❌ | Good Validation ✅ | Tier |
|-----------|------------------|-------------------|------|
| "File compiles" | `ls file.py` | `python -m py_compile file.py` | T1 |
| "Module imports" | `grep "import" file.py` | `python -c "from module import func"` | T2 |
| "Error handling works" | "Code has try/except" | `python -c "Node(state); assert state['errors']"` | T3 |
| "Graph builds" | `grep "compile" graph.py` | `python -c "g=build_graph(); list(g.nodes)"` | T3 |
| "E2E smoke test" | "Agent runs" | `python -c "result=agent.invoke(input); assert 'output' in result"` | T4 |

## Requirements Engineering Checklist

Before writing a criterion, ask:

1. **Can I run a command that proves this works?** (If not, rewrite criterion)
2. **Does my command test behavior or just syntax?** (T3+ for MUST)
3. **Can this be mocked?** (If needs external service, provide mock data)
4. **What's the exact expected output?** (Binary PASS/FAIL, no subjective)
5. **Does this command survive code changes?** (Don't test line numbers or implementation details)
6. **Is this repeatable?** (Same command = same result)

## When a Criterion Can't Be Tested

If you cannot write a validation command for a criterion:
1. **Rewrite the criterion** until it becomes testable
2. **Split the criterion** into smaller testable parts
3. **Mark as N/A** only if truly not testable (and document why)

> **Rule:** A criterion without a validation command is not a criterion — it's a wish.

## Writing Good Validation Commands

| Good ✅ | Bad ❌ |
|--------|--------|
| `python -c "from m import f; r=f(); assert r['ok']"` | `python -m py_compile m.py` (only tests syntax) |
| `python -c "g=build_graph(); assert 'node' in g.nodes"` | `grep "def build_graph" m.py` (only checks existence) |
| `python -c "Node(state); assert state['errors']"` | "Error handling exists" (not testable) |