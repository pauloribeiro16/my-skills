#!/bin/bash
# Security Hooks Setup Script
# Usage: ./setup-security-hooks.sh [project_path]

set -e

PROJECT_PATH="${1:-.}"
cd "$PROJECT_PATH"

echo "🔒 Security Hooks Setup"
echo "======================="
echo ""

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not a git repository. Run 'git init' first."
    exit 1
fi

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Error: Python 3 is required."
    exit 1
fi

# Check pip
if ! command -v pip3 &> /dev/null; then
    echo "❌ Error: pip3 is required."
    exit 1
fi

echo "📦 Installing dependencies..."
pip3 install --user pre-commit detect-secrets 2>/dev/null || pip3 install pre-commit detect-secrets

echo ""
echo "📝 Creating configuration files..."

# Create .pre-commit-config.yaml if it doesn't exist
if [ ! -f ".pre-commit-config.yaml" ]; then
    cat > .pre-commit-config.yaml << 'EOF'
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
        exclude: package.lock.json
EOF
    echo "  ✓ Created .pre-commit-config.yaml"
else
    echo "  ⚠ .pre-commit-config.yaml already exists, skipping"
fi

# Create .gitleaks.toml if it doesn't exist
if [ ! -f ".gitleaks.toml" ]; then
    cat > .gitleaks.toml << 'EOF'
title = "Gitleaks Configuration"

[extend]
useDefault = true

[[allowlists]]
description = "Ignore baseline and config files"
paths = [
  '''\.secrets\.baseline$''',
  '''\.gitleaks\.toml$''',
  '''\.gitleaksignore$''',
  '''package\.lock\.json$''',
]

[[allowlists]]
description = "Ignore test files"
paths = [
  '''test_.*\.py$''',
  '''.*_test\.py$''',
  '''tests/.*''',
]
stopwords = [
  '''test''',
  '''example''',
  '''mock''',
  '''dummy''',
  '''fake''',
]
EOF
    echo "  ✓ Created .gitleaks.toml"
else
    echo "  ⚠ .gitleaks.toml already exists, skipping"
fi

# Create baseline if it doesn't exist
if [ ! -f ".secrets.baseline" ]; then
    detect-secrets scan > .secrets.baseline 2>/dev/null || true
    if [ -f ".secrets.baseline" ]; then
        echo "  ✓ Created .secrets.baseline"
    else
        echo "  ⚠ Could not create .secrets.baseline (may be empty repo)"
    fi
else
    echo "  ⚠ .secrets.baseline already exists, skipping"
fi

echo ""
echo "🔧 Installing pre-commit hooks..."
pre-commit install --install-hooks

echo ""
echo "📂 Creating GitHub Actions workflow..."
mkdir -p .github/workflows

if [ ! -f ".github/workflows/security.yml" ]; then
    cat > .github/workflows/security.yml << 'EOF'
name: Security Check

on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]

permissions:
  contents: read

jobs:
  gitleaks:
    name: Gitleaks Scan
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Run Gitleaks
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  detect-secrets:
    name: Detect Secrets
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install detect-secrets
        run: pip install detect-secrets

      - name: Scan for secrets
        run: detect-secrets-hook --baseline .secrets.baseline $(git ls-files)
EOF
    echo "  ✓ Created .github/workflows/security.yml"
else
    echo "  ⚠ .github/workflows/security.yml already exists, skipping"
fi

echo ""
echo "📊 Creating calibration log..."
if [ ! -f "HOOK_CALIBRATION_LOG.md" ]; then
    cat > HOOK_CALIBRATION_LOG.md << 'EOF'
# Hook Calibration Log

| Date | Hook | Finding | File | False Positive? | Action | Validated |
|------|------|---------|------|-----------------|--------|-----------|

## Notes

- FALSE POSITIVE: The finding is not a real secret
- REAL SECRET: The finding is a real secret that was fixed
- TEMPLATE UPDATE: Configuration was updated to prevent future false positives
EOF
    echo "  ✓ Created HOOK_CALIBRATION_LOG.md"
else
    echo "  ⚠ HOOK_CALIBRATION_LOG.md already exists, skipping"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Review and customize .gitleaks.toml for your project"
echo "  2. Run 'detect-secrets audit .secrets.baseline' to label false positives"
echo "  3. Test with 'git commit' (hooks will run automatically)"
echo "  4. Pin GitHub Actions to SHA in .github/workflows/security.yml"
echo "  5. Commit all new files"
echo ""
echo "Useful commands:"
echo "  pre-commit run --all-files    # Test all hooks"
echo "  pre-commit autoupdate         # Update hooks to latest versions"
echo "  SKIP=gitleaks git commit      # Temporarily skip a hook"
echo ""
