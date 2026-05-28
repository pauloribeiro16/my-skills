# Gitleaks Configuration Guide

Official reference: https://github.com/gitleaks/gitleaks#configuration

## Configuration File

Gitleaks uses `.gitleaks.toml` in the project root. Order of precedence:
1. `--config/-c` option
2. `GITLEAKS_CONFIG` env var
3. `GITLEAKS_CONFIG_TOML` env var (with file content)
4. `.gitleaks.toml` in target path

## Basic Structure

```toml
title = "Project Gitleaks Configuration"

[extend]
useDefault = true  # Extend built-in rules
# OR
# path = "common_config.toml"

# Disable specific default rules
disabledRules = ["generic-api-key"]
```

## Custom Rules

```toml
[[rules]]
id = "custom-api-key"
description = "Custom API key pattern"
regex = '''(?i)(custom_api_key|custom_key)[\s]*=[\s]*['"]([a-zA-Z0-9]{32})['"]'''
secretGroup = 3
entropy = 3.5
keywords = ["custom_api_key", "custom_key"]
tags = ["api", "custom"]

[[rules.allowlists]]
description = "Ignore test keys"
paths = [
  '''test_.*\.py''',
  '''.*_test\.py'''
]
stopwords = [
  '''test''',
  '''example''',
  '''mock'''
]
```

## Global Allowlists (v8.25.0+)

```toml
[[allowlists]]
description = "Global allow list"
commits = ["commit-A", "commit-B"]
paths = [
  '''gitleaks\.toml''',
  '''\.secrets\.baseline$''',
  '''.*\.jpg$''',
  '''.*\.gif$''',
  '''.*\.doc$'''
]
regexTarget = "match"
regexes = [
  '''219-09-9999''',
  '''078-05-1120''',
]
stopwords = [
  '''client''',
  '''endpoint''',
]
```

## Composite Rules (v8.28.0+)

Composite rules combine a primary rule with required auxiliary rules.

```toml
[[rules]]
id = "database-url-with-password"
description = "Database URL containing password"
regex = '''postgres://[^:]+:([^@]+)@'''

[[rules.required]]
id = "database-keyword"
withinLines = 3
withinColumns = 50
```

## Allowlist Strategies

### 1. Inline Comment
```python
api_key = "EXAMPLE-KEY"  #gitleaks:allow  # pragma: allowlist secret
```

### 2. .gitleaksignore File
Create `.gitleaksignore` with fingerprints:
```
.commit_hash:path/to/file:rule_id:line
```

### 3. Rule-specific Allowlist
```toml
[[rules.allowlists]]
description = "Ignore test files"
condition = "OR"
paths = ['''tests/''']
stopwords = ['''test_''', '''mock_''']
```

### 4. Global Allowlist
```toml
[[allowlists]]
description = "Ignore baseline files"
paths = ['''\.secrets\.baseline$''']
```

## Decoding Support

Detect encoded secrets with `--max-decode-depth`:
```bash
gitleaks dir . --max-decode-depth 3
```

Supported encodings:
- base64
- hex
- percent-encoding

## Archive Scanning

Scan inside archives with `--max-archive-depth`:
```bash
gitleaks dir . --max-archive-depth 2
```

## Baseline

Create baseline to ignore known findings:
```bash
gitleaks git --report-path gitleaks-report.json
gitleaks git --baseline-path gitleaks-report.json
```

## Commands Reference

| Command | Purpose |
|---------|---------|
| `gitleaks git .` | Scan git history |
| `gitleaks dir .` | Scan files/directories |
| `gitleaks stdin` | Scan from stdin |
| `gitleaks git -v` | Verbose output |
| `--report-path` | Save report to file |
| `--baseline-path` | Use baseline |
| `--config` | Custom config file |
| `--exit-code` | Custom exit code |
