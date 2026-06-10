## Security Deep Dive

### Statistics

- GitHub identified **39 million leaked secrets** in 2024
- Projects using AI assistants showed **40% increase** in secrets exposure
- AI assistants may inadvertently include leaked secrets in generated code

### Never Include in AGENTS.md

**Absolutely forbidden** (the agent never sees the value, only the location):

- API keys, tokens, passwords
- Database connection strings with passwords
- AWS access keys or secret keys
- Private encryption keys or certificates
- OAuth secrets or JWT signing keys
- Production IP addresses or internal URLs
- Customer data or personally identifiable information (PII)
- Proprietary algorithms or trade secrets
- Detailed firewall or security group configurations
- Security vulnerability details

### What to Include Instead

Document **where** secrets live and **how** to access them:

```markdown
## Secrets Management

### Storage Locations
- **Production**: AWS Secrets Manager (`prod/*` namespace)
- **Staging**: AWS Secrets Manager (`staging/*` namespace)
- **Development**: Local `.env` file (gitignored, copy from `.env.example`)
- **CI/CD**: GitHub Actions Secrets

### Accessing in Code
# Python example — retrieve from secrets manager
import boto3
secrets_client = boto3.client('secretsmanager')
secret = secrets_client.get_secret_value(SecretId='prod/api-key')

# NEVER: api_key = "sk_live_abc123..."
```

### Required Environment Variables (Structure Only)

```markdown
- `DATABASE_URL`: PostgreSQL connection (format: postgresql://user:pass@host:port/db)
- `API_KEY`: External API auth (retrieve from secrets manager)
- `JWT_SECRET`: Token signing (minimum 32 characters, from secrets manager)
```

### Environment Variables Are NOT Secure

Significant limitations:
- Accessible to all spawned child processes
- Readable via `/proc` or `ps` commands by any process with same user
- Often inadvertently logged in error messages or crash reports
- No built-in auditing

> **CNCF Cloud Native Security Whitepaper**: "Secrets should be injected at runtime within workloads through non-persistent mechanisms that are immune to leaks via logs, audit, or system dumps (i.e., in-memory shared volumes instead of environment variables)."

**Better alternatives**: AWS Secrets Manager, HashiCorp Vault, Azure Key Vault, Kubernetes secrets as tmpfs volumes, encrypted secrets files with proper permissions.

### Security Scanning Tools

**Pre-commit checks**:
```bash
detect-secrets scan --all-files    # Secret scanning
pip-audit                           # Dependency vulnerabilities
bandit -r src/                      # Code security
tfsec infrastructure/               # Terraform security
```

**CI/CD Security Gates**:
- GitHub push protection (blocks commits with secrets)
- Snyk (dependency vulnerabilities)
- Semgrep (code patterns and security rules)
- All scans must pass before merge allowed

**AWS Security Practices**:
- Use IAM roles for Lambda (principle of least privilege)
- Enable CloudTrail for audit logging
- Encrypt DynamoDB tables at rest
- Use VPC for sensitive Lambda functions
- Enable S3 bucket encryption and versioning
- Rotate IAM access keys quarterly

### CI/CD Documentation Pattern

Document the complete pipeline in AGENTS.md:

```markdown
## CI/CD Pipeline

### GitHub Actions
- **CI**: `.github/workflows/ci.yml` (runs on all PRs)
  - Stages: Lint → Type Check → Unit Tests → Security Scan → Build
- **Deploy**: `.github/workflows/deploy.yml` (runs on main)
  - Stages: Integration Tests → Plan → Manual Approval → Apply

### Local CI Simulation
# Run all checks locally before pushing
pytest tests/unit/
black --check src/
terraform fmt -check -recursive
```

### Deployment Gates

Define what must be true before deployment:

```markdown
### Merge Requirements
- All CI checks pass
- Code coverage ≥80%
- No high/critical severity vulnerabilities
- At least one approved code review
- Branch protection rules enforced

### Production Gates
1. Successful staging deployment and smoke tests
2. Manual approval from team lead
3. Deployment window (weekdays, no Fridays)
4. Rollback plan documented in deployment PR
```

### Post-Deployment Validation

```bash
# Health check
curl https://api.example.com/health

# Logs
aws logs tail /aws/lambda/api --follow

# Smoke tests
pytest tests/smoke/
```
