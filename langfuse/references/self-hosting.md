# Langfuse Self-Hosting

## Overview

Langfuse can be self-hosted using Docker Compose. This gives you full control over your data and infrastructure.

## Architecture

### Components

| Component | Purpose | Technology |
|-----------|---------|------------|
| **Langfuse Web** | Web application and API server | Next.js (Node.js) |
| **Langfuse Worker** | Background job processing | Node.js |
| **Postgres** | Primary database — metadata, traces, scores | PostgreSQL 15+ |
| **ClickHouse** | Analytics database — high-volume events, observability data | ClickHouse |
| **Redis** | Caching and job queue | Redis 7+ |
| **MinIO** (optional) | Object storage for media/assets | MinIO |

## Docker Compose Setup

### Minimal docker-compose.yml

```yaml
version: "3"
services:
  langfuse:
    image: ghcr.io/langfuse/langfuse:latest
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://postgres:postgres@postgres:5432/langfuse
      - NEXTAUTH_SECRET=your-secret-key-min-32-characters-long
      - SALT=your-salt-min-32-characters-long
      - ENCRYPTION_KEY=your-encryption-key-32-characters
      - CLICKHOUSE_URL=http://clickhouse:8123
      - REDIS_HOST=redis
      - REDIS_PORT=6379
    depends_on:
      - postgres
      - clickhouse
      - redis

  postgres:
    image: postgres:15
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=langfuse
    volumes:
      - postgres_data:/var/lib/postgresql/data

  clickhouse:
    image: clickhouse/clickhouse-server:latest
    volumes:
      - clickhouse_data:/var/lib/clickhouse

  redis:
    image: redis:7
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  clickhouse_data:
  redis_data:
```

## Environment Variables

### Required

| Variable | Description |
|----------|-------------|
| `DATABASE_URL` | PostgreSQL connection string |
| `NEXTAUTH_SECRET` | Secret for session encryption (min 32 chars) |
| `SALT` | Salt for API key hashing (min 32 chars) |
| `ENCRYPTION_KEY` | Key for sensitive data encryption (exactly 32 chars) |
| `CLICKHOUSE_URL` | ClickHouse connection URL |

### Optional

| Variable | Description | Default |
|----------|-------------|---------|
| `REDIS_HOST` | Redis hostname | `localhost` |
| `REDIS_PORT` | Redis port | `6379` |
| `LANGFUSE_PORT` | Web server port | `3000` |
| `TELEMETRY_ENABLED` | Enable anonymous telemetry | `true` |

## Deployment Checklist

- [ ] Generate strong secrets for `NEXTAUTH_SECRET`, `SALT`, and `ENCRYPTION_KEY`
- [ ] Configure persistent volumes for all data stores
- [ ] Set up backup strategy for Postgres and ClickHouse
- [ ] Configure reverse proxy (nginx/traefik) with TLS
- [ ] Set resource limits (Postgres: 2GB RAM minimum, ClickHouse: 4GB RAM recommended)
- [ ] Enable monitoring for component health
- [ ] Configure log aggregation
- [ ] Set up alerting for disk space and memory

## Upgrading

1. Backup Postgres and ClickHouse data
2. Update image tags in docker-compose.yml
3. Run `docker-compose pull && docker-compose up -d`
4. Check logs for migration status: `docker-compose logs -f langfuse`

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Langfuse won't start | Check all required env vars are set |
| Database connection failed | Verify Postgres is running and `DATABASE_URL` is correct |
| ClickHouse timeouts | Ensure ClickHouse container is healthy |
| High memory usage | Increase ClickHouse memory limit or reduce retention |

## Official Resources

- [Self-Hosting Guide](https://langfuse.com/docs/deployment/self-host)
- [Docker Hub](https://hub.docker.com/r/langfuse/langfuse)
- [GitHub Releases](https://github.com/langfuse/langfuse/releases)
