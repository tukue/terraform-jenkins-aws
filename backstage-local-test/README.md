# Backstage Local Test - Legacy Helper

This directory is a legacy helper for validating local Backstage catalog behavior.

It is no longer the primary local Backstage path for this repository.

Use the root `Makefile` targets and the checked-in `backstage-app/` first:

```bash
make backstage-validate
make local-up
```

Use this directory only if you need to inspect the older single-container test setup directly.

## Prerequisites

- Docker and Docker Compose
- GitHub Personal Access Token (for catalog discovery and scaffolding)

## Legacy Quick Start

1. **Set up environment variables:**
   Create a `.env` file in this directory:
   ```bash
   GITHUB_TOKEN=your_github_token
   ```

2. **Start the legacy Backstage stack:**
   ```bash
   docker compose up -d
   ```

3. **Verify services:**
   - Backstage: [http://localhost:7000](http://localhost:7000)

4. **Accessing the Catalog:**
   Once Backstage is up, you should see the `terraform-jenkins-aws` component and the `internal-developer-platform` system in the catalog.

5. **Testing Templates:**
   Go to the "Create" page in Backstage to see and test the following templates:
   - Jenkins EC2 Instance
   - Customer ECS Runtime

## What This Directory Is For

- `docker-compose.yml`: Old single-container local test setup
- `app-config.yaml`: Legacy local config used by that container
- `test-catalog.js`: Lightweight catalog validation script still useful from the repo root

## Troubleshooting

- **Startup Errors:** Review `docker compose logs backstage` and ensure ports `7000` and `7007` are free.
- **GitHub Rate Limiting:** If catalog discovery fails, ensure your `GITHUB_TOKEN` is valid and has `repo` and `read:org` permissions.
- **File Not Found:** The container expects the repository root at `/repo`. This is handled by the volume mount in `docker-compose.yml`.
