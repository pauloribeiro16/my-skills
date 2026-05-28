# Security Hooks Setup Walkthrough

Complete example of setting up security hooks for a Python project.

## Prerequisites

- Python 3.8+
- Git repository initialized
- pip installed

## Step 1: Install pre-commit

```bash
pip install pre-commit detect-secrets
```

Or add to requirements:
```txt
# requirements-dev.txt
pre-commit
detect-secrets
```

## Step 2: Create Pre-commit Config

Copy from template:
```bash
cp security-hooks/templates/.pre-commit-config.yaml .
```

Or create manually:
```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.6.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files

  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.24.2
    hooks:
      - id: gitleaks
        args: ['--config', '.gitleaks.toml']

  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.5.0
    hooks:
      - id: detect-secrets
        args: ['--baseline', '.secrets.baseline']
```

## Step 3: Create Gitleaks Config

```bash
cp security-hooks/templates/.gitleaks.toml .
```

Edit to add project-specific allowlists:
```toml
[[allowlists]]
description = "Ignore my project's test data"
paths = ['''tests/data/.*''']
stopwords = ['''test_key_''']
```

## Step 4: Create Detect-secrets Baseline

```bash
detect-secrets scan > .secrets.baseline
```

This creates a snapshot of currently detected secrets. You'll audit this later.

## Step 5: Install Hooks

```bash
pre-commit install --install-hooks
```

Output:
```
pre-commit installed at .git/hooks/pre-commit
```

## Step 6: Test with a Commit

Create a test file:
```python
# test_secret.py (this will be caught)
API_KEY = "EXAMPLE-KEY-1234567890abcdef"  # pragma: allowlist secret
```

Stage and try to commit:
```bash
git add test_secret.py
git commit -m "test: add secret"
```

Expected output:
```
Detect secrets (gitleaks)................................................Failed
- hook id: gitleaks
- exit code: 1

Finding:     "API_KEY = "EXAMPLE-KEY""  # pragma: allowlist secret
Secret:      EXAMPLE-KEY-1234567890abcdef
RuleID:      generic-api-key
...
```

## Step 7: Fix the Secret

Remove the test file or use environment variables:
```python
# config.py (fixed)
import os

API_KEY = os.environ.get("API_KEY")
```

## Step 8: Handle False Positives

If a legitimate value is flagged:

### Option A: Inline allowlist (for single cases)
```python
TEST_KEY = "test-example-key-1234567890abcdef"  # pragma: allowlist secret
```

### Option B: Gitleaks allowlist (for patterns)
Add to `.gitleaks.toml`:
```toml
[[allowlists]]
description = "Ignore test keys"
stopwords = ['''test-''']
```

### Option C: Detect-secrets baseline (recommended)
```bash
detect-secrets audit .secrets.baseline
# Mark false positives as "False Positive"
detect-secrets scan --baseline .secrets.baseline
```

## Step 9: Create GitHub Actions Workflow

```bash
mkdir -p .github/workflows
cp security-hooks/templates/security.yml .github/workflows/security.yml
```

**Important:** Pin actions to SHA in production:
```yaml
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11  # v4.1.1
```

## Step 10: Verify CI

Push to GitHub:
```bash
git add -A
git commit -m "chore: add security hooks"
git push
```

Check Actions tab for green builds.

## Step 11: Calibration Log

Create `HOOK_CALIBRATION_LOG.md`:
```markdown
# Hook Calibration Log

| Date | Hook | Finding | File | False Positive? | Action | Validated |
|------|------|---------|------|-----------------|--------|-----------|
| 2024-01-15 | gitleaks | generic-api-key | tests/conftest.py | YES | Added stopword "test-" to .gitleaks.toml | 2024-01-20 |
```

## Maintenance

### Weekly
- Review `HOOK_CALIBRATION_LOG.md`
- Update false positive handling

### Monthly
- Run `pre-commit autoupdate` to update hooks
- Re-audit baseline: `detect-secrets audit .secrets.baseline`

### As Needed
- Update `.gitleaks.toml` for new false positive patterns
- Refresh baseline when adding new test data

## Troubleshooting

### Hook too slow
- Use `--max-decode-depth 0` to disable decoding
- Exclude large directories in `.gitleaks.toml`

### Too many false positives
- Audit baseline thoroughly
- Add global allowlists for common patterns
- Use inline comments for one-off cases

### Baseline out of sync
```bash
detect-secrets scan --baseline .secrets.baseline
```

### Want to skip a hook temporarily
```bash
SKIP=gitleaks git commit -m "temporary skip"
```

**Note:** Only skip hooks in exceptional cases. Never skip in CI.
