# GitHub Actions Security Best Practices

Official reference: https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions

## Core Principles

### 1. Pin Actions to SHA (Not Tags)

**❌ Bad:**
```yaml
uses: actions/checkout@v4
```

**✅ Good:**
```yaml
uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11  # v4.1.1
```

**Why:** Tags can be moved or deleted. SHA is immutable.

### 2. Use Least Privilege Permissions

**❌ Bad:**
```yaml
# No permissions specified (defaults to write-all)
```

**✅ Good:**
```yaml
permissions:
  contents: read
```

**For specific jobs:**
```yaml
jobs:
  build:
    permissions:
      contents: read
      security-events: write
```

### 3. Never Use Structured Data as Secrets

**❌ Bad:**
```yaml
env:
  CONFIG: '{"api_key": "EXAMPLE-KEY", "password": "EXAMPLE-PASS"}'  # pragma: allowlist secret
```

**✅ Good:**
```yaml
env:
  API_KEY: ${{ secrets.API_KEY }}
  PASSWORD: ${{ secrets.PASSWORD }}
```

### 4. Mask Sensitive Values

```yaml
- run: echo "::add-mask::${{ secrets.MY_SECRET }}"
```

### 5. Use Environment Variables for Untrusted Input

**❌ Bad:**
```yaml
- run: echo "${{ github.event.pull_request.title }}"
```

**✅ Good:**
```yaml
- run: echo "$PR_TITLE"
  env:
    PR_TITLE: ${{ github.event.pull_request.title }}
```

## Workflow Security Template

```yaml
name: Security Scan

on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]

permissions:
  contents: read  # Least privilege

jobs:
  gitleaks:
    name: Gitleaks Scan
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@<SHA>  # Pinned
        with:
          fetch-depth: 0

      - name: Run Gitleaks
        uses: gitleaks/gitleaks-action@<SHA>
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  detect-secrets:
    name: Detect Secrets
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@<SHA>

      - name: Set up Python
        uses: actions/setup-python@<SHA>
        with:
          python-version: '3.11'

      - name: Install detect-secrets
        run: pip install detect-secrets

      - name: Scan for secrets
        run: detect-secrets-hook --baseline .secrets.baseline $(git ls-files)
```

## GITHUB_TOKEN Permissions

### Default (read-only)
```yaml
permissions:
  contents: read
```

### Job-specific
```yaml
jobs:
  deploy:
    permissions:
      contents: read
      id-token: write  # For OIDC
```

## CODEOWNERS for Workflow Protection

Create `.github/CODEOWNERS`:
```
# Require review for workflow changes
.github/workflows/ @security-team
```

## OpenID Connect (OIDC)

Use OIDC for cloud authentication instead of long-lived secrets:
```yaml
permissions:
  id-token: write
  contents: read

steps:
  - uses: aws-actions/configure-aws-credentials@<SHA>
    with:
      role-to-assume: arn:aws:iam::ACCOUNT:role/ROLE
      aws-region: us-east-1
```

## Self-hosted Runners

### ⚠️ Security Risks
- Not ephemeral (can be compromised persistently)
- Public repositories: **Never use self-hosted runners**
- Private repositories: Use with caution

### Mitigations
- Use JIT (just-in-time) runners
- Group runners by trust boundary
- Minimize secrets on runner machines

## Dependabot for Actions

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

## Audit and Monitoring

- Use audit log to track `org.update_actions_secret` events
- Enable Dependabot alerts for vulnerable actions
- Use dependency review action for PRs

## Security Checklist

- [ ] All actions pinned to SHA
- [ ] Permissions set to `contents: read` minimum
- [ ] No structured data as secrets
- [ ] Untrusted input via env vars
- [ ] CODEOWNERS for workflow files
- [ ] Dependabot enabled for actions
- [ ] Self-hosted runners restricted
- [ ] Audit logs reviewed regularly
