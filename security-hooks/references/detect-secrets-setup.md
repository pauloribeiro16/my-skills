# Detect-secrets Setup Guide

Official reference: https://github.com/Yelp/detect-secrets

## Installation

```bash
pip install detect-secrets
```

For additional features:
```bash
pip install detect-secrets[word_list]     # Word list support
pip install detect-secrets[gibberish]     # Gibberish detection
```

## Basic Commands

### Scan Repository
```bash
# Create baseline
detect-secrets scan > .secrets.baseline

# Scan non-git files
detect-secrets scan --all-files > .secrets.baseline

# Update existing baseline
detect-secrets scan --baseline .secrets.baseline
```

### Pre-commit Hook
```bash
# Scan staged files
git diff --staged --name-only -z | xargs -0 detect-secrets-hook --baseline .secrets.baseline

# Scan all tracked files
git ls-files -z | xargs -0 detect-secrets-hook --baseline .secrets.baseline
```

### Audit Baseline
```bash
# Interactive audit of false positives
detect-secrets audit .secrets.baseline

# Show statistics
detect-secrets audit --stats .secrets.baseline

# Show report
detect-secrets audit --report .secrets.baseline
```

## Baseline Management

### Initial Setup
```bash
detect-secrets scan > .secrets.baseline
```

### Update (preserve labels)
```bash
detect-secrets scan --baseline .secrets.baseline
```

### Slim Baseline
```bash
detect-secrets scan --slim > .secrets.baseline
```
Note: Slim baselines are not compatible with `audit` functionality.

## Inline Allowlisting

### Python
```python
API_KEY = 'this-will-ordinarily-be-detected'  # pragma: allowlist secret
```

### Next Line
```python
# pragma: allowlist nextline secret
API_KEY = 'WillAlsoBeIgnored'
```

### JavaScript
```javascript
const secret = "something-secret-here";  //  pragma: allowlist secret
```

## Plugins

### View All Plugins
```bash
detect-secrets scan --list-all-plugins
```

### Disable Specific Plugins
```bash
detect-secrets scan --disable-plugin AWSKeyDetector --disable-plugin Base64HighEntropyString
```

### Custom Plugin
```python
from detect_secrets.plugins.base import RegexBasedDetector

class CustomDetector(RegexBasedDetector):
    secret_type = 'Custom API Key'  # pragma: allowlist secret
    denylist = [
        re.compile(r'custom_key_[a-zA-Z0-9]{32}'),
    ]
```

## Filters

### Exclude Lines
```bash
detect-secrets scan --exclude-lines 'password = (blah|fake)'
```

### Exclude Files
```bash
detect-secrets scan --exclude-files '.*\.signature$'
```

### Exclude Secrets
```bash
detect-secrets scan --exclude-secrets '(fakesecret|\${.*})'
```

### Word List
```bash
detect-secrets scan --word-list wordlist.txt
```

## Configuration in Pre-commit

```yaml
repos:
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.5.0
    hooks:
      - id: detect-secrets
        args: ['--baseline', '.secrets.baseline']
        exclude: package.lock.json
```

## Baseline Structure

```json
{
  "version": "1.5.0",
  "plugins_used": [...],
  "filters_used": [...],
  "results": {
    "path/to/file": [
      {
        "type": "AWS Access Key",
        "filename": "path/to/file",
        "hashed_secret": "abc123...",  # pragma: allowlist secret
        "is_verified": false,
        "line_number": 42
      }
    ]
  },
  "generated_at": "2024-01-01T00:00:00Z"
}
```

## Best Practices

1. **Create baseline on first setup** — Not all existing secrets can be fixed immediately
2. **Audit baseline regularly** — Label false positives to reduce noise
3. **Update baseline when adding exclusions** — Use `--baseline` flag
4. **Use inline comments sparingly** — Prefer baseline for project-wide false positives
5. **Review slim baselines** — Trade-off between size and auditability

## Common Issues

### "Did not detect git repository"
- Check git version >= 1.8.5
- Run from within a git repository

### Baseline encoding issues (Windows)
- Ensure baseline file is UTF-8 encoded

### Audit shows "Not a valid baseline file!"
- Recreate baseline if older than version 0.9
