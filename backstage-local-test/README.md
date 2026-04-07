# Backstage Local Test - Platform as a Product

This directory provides a functional local Backstage instance to test the "Platform as a Product" experience. It uses Docker Compose to run Backstage and PostgreSQL, pre-configured to load the catalog and templates from this repository.

## Prerequisites

- Docker and Docker Compose
- GitHub Personal Access Token (for catalog discovery and scaffolding)

## Quick Start

1. **Set up environment variables:**
   Create a `.env` file in this directory:
   ```bash
   GITHUB_TOKEN=your_github_token
   ```

2. **Start the Backstage stack:**
   ```bash
   docker compose up -d
   ```

3. **Verify services:**
   - Backstage: [http://localhost:3000](http://localhost:3000)
   - PostgreSQL: `localhost:5432`

4. **Accessing the Catalog:**
   Once Backstage is up, you should see the `terraform-jenkins-aws` component and the `jenkins-platform` system in the catalog.

5. **Testing Templates:**
   Go to the "Create" page in Backstage to see and test the following templates:
   - Jenkins EC2 Instance
   - Customer ECS Runtime

## Configuration Details

- `docker-compose.yml`: Defines the Backstage and PostgreSQL services. It mounts the repository root to `/repo` inside the container to allow Backstage to read local files.
- `app-config.yaml`: The Backstage configuration file, loaded as `app-config.local.yaml` in the container.
- `test-catalog.js`: A legacy script to validate catalog YAML files without running a full Backstage instance.

## Troubleshooting

- **Database Errors:** If the database fails to start, ensure port `5432` is not already in use.
- **GitHub Rate Limiting:** If catalog discovery fails, ensure your `GITHUB_TOKEN` is valid and has `repo` and `read:org` permissions.
- **File Not Found:** The container expects the repository root at `/repo`. This is handled by the volume mount in `docker-compose.yml`.
