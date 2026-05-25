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
| CLAUDE.md compliance ×2 | Verify guideline adherence | Two agents for redundancy |
| Bug detection | Scan for obvious bugs | Changes only, not pre-existing |
| Historical context | Git blame analysis | Context from git history |

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
- General quality issues (unless in AGENTS.md)
- Issues with lint ignore comments

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