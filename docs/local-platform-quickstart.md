# Local Platform Quickstart

Use this flow when you want to provision the platform components locally before running any AWS-backed Terraform.

There are two supported local paths:

- `make local-up` for the full Docker-based stack
- `make backstage-start` for a host-only Backstage run when Docker is unavailable

## What Starts

`make local-up` starts a single local stack from [docker-compose.local.yaml](../docker-compose.local.yaml):

- Backstage UI on `http://localhost:7000`
- Backstage backend on `http://localhost:7007`
- Vault dev server on `http://localhost:8200`
- Prometheus on `http://localhost:9090`
- Grafana on `http://localhost:3001`

The Backstage container mounts this repository at `/repo`, so the local portal reads:

- root `catalog-info.yaml`
- `.backstage/` entities
- scaffolder templates under `templates/`

## Commands

Start everything:

```bash
make local-up
```

Install Backstage dependencies for the host-only path:

```bash
make backstage-install
```

Start Backstage directly on the host:

```bash
make backstage-start
```

See exposed endpoints:

```bash
make local-health
```

See running containers:

```bash
make local-ps
```

Stop everything:

```bash
make local-down
```

## Local Provisioning Path

1. Start the stack with `make local-up` or `make backstage-start`.
2. Open Backstage at `http://localhost:7000`.
3. Start from the `Platform Home` landing page to review the supported products and entry points.
4. Open the `Create` page.
5. Use `Create Customer ECS Runtime`, `Create Jenkins EC2 Instance`, or `Create Standard Service Deployment`.
6. Review the generated infrastructure definition before moving to AWS-backed applies.

## Notes

- `GITHUB_TOKEN` is optional for basic local catalog browsing but helps with scaffolder publishing flows.
- `make backstage-start` sets `REPO_ROOT` automatically so Backstage can read this repository directly instead of the Docker-only `/repo` mount.
- Vault runs in dev mode with root token `root`.
- Backstage uses embedded SQLite in memory for the local workflow, so no separate database container is required.
- This local stack is for platform workflow testing, not production posture.
