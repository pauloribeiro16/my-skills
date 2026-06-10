---
name: code-review
description: "Automated code review using multiple specialized agents with confidence-based scoring. Trigger phrases: review code, review pull request, analyze code quality, run code review, automated review"
---

# Code Review

Automated code review using multiple specialized agents with confidence-based scoring to filter false positives. Based on Anthropic's code-review plugin.

## When to Use

- Reviewing pull requests before merge
- Running automated code review on a branch
- Auditing code for bugs and quality issues
- Verifying CLAUDE.md/AGENTS.md compliance
- Post-implementation review

**Do not use for**: Trivial changes, already reviewed PRs, or urgent hotfixes.

## How It Works

```
1. Analyze PR changes
2. Launch 4 parallel agents:
   ├── CLAUDE.md compliance agent (×2)
   ├── Bug detection agent
   └── Historical context agent
3. Score each issue 0-100 for confidence
4. Filter issues below threshold (default: 80)
5. Output actionable review
```

## Agent Architecture

| Agent | Purpose | Focus |
|-------|---------|-------|
| AGENTS.md compliance ×2 | Verify guideline adherence | Two agents for redundancy |
| **Convention compliance** | Verify `project-conventions` skill rules | Naming, structure, error handling, ports |
| Bug detection | Scan for obvious bugs | Changes only, not pre-existing |
| Historical context | Git blame analysis | Context from git history |

## Convention Compliance Check (AEGIS-KG specific)

**Before scoring confidence**, run the convention validation commands from `.opencode/skills/project-conventions/SKILL.md` §13. The following are **HARD BLOCKERS** (automatic FAIL):

| Check | Command | Threshold |
|-------|---------|-----------|
| Hardcoded wrong ports | `grep -rn "7474\|7687" core/ cases/` | 0 matches |
| Bare `except: pass` | `ruff check --select SIM105,SIM110` | 0 errors |
| Old-style type hints | `ruff check --select UP006,UP007` | 0 errors |
| Missing logger in module | `grep -L "logger = logging.getLogger(__name__)"` on files with functions | 0 files |
| Neo4j nodes without `case` property | Code review of new Cypher | 0 nodes |
| Naming convention violations | `ruff check --select N801,N802,N803` | 0 errors |
| Hardcoded credentials | `grep -rn "d3fendtest" core/ cases/` | 0 matches in active code |

**Soft warnings** (lower confidence, do not block):
- Missing docstrings on public functions
- Mutable default arguments
- Functions >50 lines
- Files >500 lines

**If ANY hard blocker is found**, the review verdict is **FAIL** regardless of confidence scores.

## Confidence Scoring

Each issue is scored 0-100:

| Score | Meaning |
|-------|---------|
| 0-24 | False positive |
| 25-49 | Might be real, low confidence |
| 50-74 | Real but minor |
| 75-99 | Real and important |
| 100 | Absolutely certain |

**Default threshold: 80** — only report issues ≥80 confidence.

## Review Output Format

```markdown
## Code Review

Found 3 issues:

1. Missing error handling (src/auth.ts:67-72)
   Confidence: 85
   Evidence: CLAUDE.md says "Always handle errors"
   Fix: Add try/catch around async operation

2. Memory leak: OAuth state not cleaned up (src/auth.ts:88-95)
   Confidence: 90
   Evidence: Missing cleanup in finally block
   Fix: Add state.cleanup() in finally

3. Inconsistent naming (src/utils.ts:23-28)
   Confidence: 82
   Evidence: camelCase expected, found snake_case
   Fix: Rename to camelCase
```

## What Gets Filtered

Issues **not reported** (below threshold):

- Pre-existing issues not introduced in changes
- Code that looks like a bug but isn't
- Pedantic nitpicks
- Issues linters will catch
- General quality issues (unless in AGENTS.md or project-conventions skill)
- Issues with lint ignore comments

## Mandatory Pre-Review Checklist

Before running the code review, ALWAYS execute:

```bash
cd "/home/epmq-cyber/Área de Trabalho/projects/aegis-kg"

echo "=== HARD BLOCKER 1: Wrong ports ===" && \
result=$(grep -rn "7474\|7687" core/ cases/ 2>/dev/null | grep -v "archive\|AGENTS\|README\|example" || true) && \
if [ -z "$result" ]; then echo "OK"; else echo "FAIL: $result"; fi

echo "=== HARD BLOCKER 2: Bare except: pass ===" && \
python3 -m ruff check core/ --select SIM105,SIM110

echo "=== HARD BLOCKER 3: Old-style type hints ===" && \
python3 -m ruff check core/ --select UP006,UP007

echo "=== HARD BLOCKER 4: Hardcoded credentials ===" && \
grep -rn "d3fendtest" core/ cases/ 2>/dev/null | grep -v "archive\|defaults.py\|test_" | head

echo "=== HARD BLOCKER 5: Naming conventions ===" && \
python3 -m ruff check core/ --select N801,N802,N803
```

If ANY of these returns errors, the review is **automatic FAIL** with the specific blocker cited.

## Usage

### Full PR review
```
/code-review
```

### Post review as PR comment
```
/code-review --comment
```

## Requirements

- Git repository with changes to review
- CLAUDE.md or AGENTS.md files (optional but recommended)
- Git CLI available for blame analysis

## Best Practices

1. **Write specific AGENTS.md/CLAUDE.md files**: Clear guidelines = better reviews
2. **Trust the threshold**: 80 filters most false positives
3. **Iterate on guidelines**: Update AGENTS.md based on recurring patterns
4. **Review agent findings**: Agents provide structured analysis
5. **Use before merge**: Catch issues before they reach production

## Configuration

### Adjust confidence threshold

Default is 80. To adjust:

```markdown
Filter out any issues with a score less than <threshold>.
```

### Customize review focus

Add or modify agent tasks:
- Security-focused agents
- Performance analysis agents
- Accessibility checking agents
- Documentation quality checks
