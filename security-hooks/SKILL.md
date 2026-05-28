---
name: security-hooks
description: "Setup security hooks and CI workflows for secret detection in any project. Configure pre-commit with gitleaks and detect-secrets, GitHub Actions security scanning, manage false positives, and maintain baselines. Trigger phrases: setup security hooks, configure gitleaks, add pre-commit, detect secrets, setup secret scanning, security baseline, configure detect-secrets"
---

# Security Hooks Skill

Setup secret detection hooks and CI workflows for any project. Based on official documentation from pre-commit, gitleaks, detect-secrets, and GitHub Actions security best practices.

## When to Use

- "setup security hooks" — Configure pre-commit and CI for a new project
- "configure gitleaks" — Setup gitleaks secret detection
- "add pre-commit" — Install pre-commit framework with security hooks
- "detect secrets" — Scan repository for hardcoded secrets
- "setup secret scanning" — Full secret detection setup (local + CI)
- "security baseline" — Create or update secret detection baseline
- "configure detect-secrets" — Setup Yelp's detect-secrets with baseline

## What It Covers

1. **Install pre-commit framework** — `pip install pre-commit && pre-commit install`
2. **Configure gitleaks** — `.gitleaks.toml` with allowlists, custom rules, composite rules
3. **Configure detect-secrets** — Baseline creation, audit, inline allowlists, plugins
4. **Setup GitHub Actions** — CI workflow with SHA-pinned actions and least privilege permissions
5. **Handle false positives** — `.gitleaksignore`, `detect-secrets audit`, inline comments
6. **Maintain and update** — `pre-commit autoupdate`, baseline refresh, calibration log

## Workflow

```
1. Check if pre-commit is installed
   └─ If NO → install pre-commit

2. Create .pre-commit-config.yaml
   └─ Include: pre-commit-hooks, gitleaks, detect-secrets

3. Create .gitleaks.toml
   └─ Extend default config
   └─ Add project-specific allowlists

4. Create .secrets.baseline (detect-secrets)
   └─ Run: detect-secrets scan > .secrets.baseline
   └─ Audit: detect-secrets audit .secrets.baseline

5. Install hooks
   └─ pre-commit install --install-hooks

6. Create .github/workflows/security.yml
   └─ Pin actions to SHA
   └─ Set permissions: contents: read
   └─ Include: gitleaks + detect-secrets jobs

7. Test with a commit
   └─ If PASS → done
   └─ If FAIL → handle false positives (see Learning from Errors)

8. Update Calibration Log
   └─ Record any adjustments made
```

## Learning from Errors

When hooks fail, the system learns from errors to reduce false positives over time.

### Calibration Workflow

```
1. Hook fails on commit → STOP
2. Analyze the finding:
   a) Is it a real secret? → Fix in code → retry
   b) Is it a false positive? → Add to allowlist/baseline → retry
3. Record in HOOK_CALIBRATION_LOG.md
4. After 3 similar false positives → update template/config
5. If real secret found 3+ times → strengthen detection rules
```

### Calibration Log Format

Create `HOOK_CALIBRATION_LOG.md` in project root:

```markdown
# Hook Calibration Log

| Date | Hook | Finding | File | False Positive? | Action | Validated |
|------|------|---------|------|-----------------|--------|-----------|
| YYYY-MM-DD | gitleaks | generic-api-key | .secrets.baseline | YES | Added to .gitleaksignore | 2024-01-15 |
| YYYY-MM-DD | detect-secrets | AWSKeyDetector | tests/mock.py | YES | Added baseline entry | 2024-01-20 |
```

### Handling False Positives

**Gitleaks:**
- Inline: `api_key = "EXAMPLE-VALUE"  #gitleaks:allow`
- `.gitleaksignore`: Add fingerprint from gitleaks report
- `.gitleaks.toml`: Add global or rule-specific allowlist

**Detect-secrets:**
- Inline: `secret = "value"  # pragma: allowlist secret`
- Baseline: Run `detect-secrets audit .secrets.baseline` to label false positives
- Re-scan: `detect-secrets scan --baseline .secrets.baseline`

## Templates Available

| Template | Path | Description |
|----------|------|-------------|
| Pre-commit config | `security-hooks/templates/.pre-commit-config.yaml` | Full pre-commit setup with security hooks |
| GitHub Actions | `security-hooks/templates/security.yml` | CI workflow for gitleaks + detect-secrets |
| Gitleaks config | `security-hooks/templates/.gitleaks.toml` | Gitleaks configuration with best practices |
| Baseline | `security-hooks/templates/.secrets.baseline` | Empty detect-secrets baseline placeholder |

## Resources

- **Core SKILL.md** — This file
- `references/gitleaks-config-guide.md` — Gitleaks rules, allowlists, composite rules
- `references/detect-secrets-setup.md` — Baseline management, audit, plugins
- `references/github-actions-security.md` — SHA pinning, permissions, CODEOWNERS
- `examples/setup-walkthrough.md` — Complete setup example step-by-step
- `scripts/setup-security-hooks.sh` — Automated setup script

## Best Practices Summary

### Pre-commit
- Use `pre-commit install --install-hooks` to install everything at once
- Run `pre-commit run --all-files` when adding new hooks
- Use `pre-commit autoupdate` to keep hooks updated
- Pin to SHA for immutability: `rev: 0161422b...  # frozen: v2.4.0`

### Gitleaks
- Always use `.gitleaks.toml` for project-specific config
- Use baseline to ignore known findings: `--baseline-path`
- Prefer `.gitleaksignore` for one-off false positives
- Use composite rules (v8.28.0+) for complex detection patterns

### Detect-secrets
- Create baseline on first setup: `detect-secrets scan > .secrets.baseline`
- Audit baseline periodically: `detect-secrets audit .secrets.baseline`
- Update baseline when adding new false positives
- Use inline allowlist comments for test data

### GitHub Actions
- **Always pin actions to full SHA** (not tags)
- Set `permissions: contents: read` (least privilege)
- Use `GITHUB_TOKEN` with minimal permissions
- Add CODEOWNERS for `.github/workflows/`

## Use When

Use this skill when:
- Starting a new project that needs secret detection
- Adding security scanning to an existing project
- Configuring CI/CD pipelines with secret detection
- Managing false positives in secret detection tools
- Setting up pre-commit hooks for a team

**Note:** This skill focuses exclusively on secret detection. For broader security (SAST, dependency scanning), consider additional tools like CodeQL, Semgrep, or Dependabot.
