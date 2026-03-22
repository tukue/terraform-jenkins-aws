# Backstage Platform Portal

This directory contains the Backstage deployment and local development setup for the platform portal.

Backstage is the front door for both platform tracks:

- Jenkins platform provisioning and discovery
- ECS customer runtime self-service provisioning

## Local Development

Use Docker Compose from this directory to run Backstage and PostgreSQL locally:

```bash
cp .env.example .env
docker compose up -d
docker compose ps
```

Backstage will be available at `http://localhost:3000`.

Grafana will be available at `http://localhost:3001` and Prometheus at `http://localhost:9090`.

The Backstage Create page includes the customer ECS runtime template, where users enter AWS account and AWS region for provisioning.

## Contents

- `docker-compose.yml` - local Backstage stack
- `app-config-plugins.yaml` - catalog, scaffolder, and plugin configuration
- `main.tf` - Backstage infrastructure root module
- `backstage.tf` - EC2 and database deployment
- `modules/` - reusable Backstage infrastructure modules

## What To Look At

- Use the catalog for platform components and runtime discovery.
- Use the Create page for self-service ECS runtime provisioning.
- Use the Jenkins-related docs and modules for the CI/CD platform track.
