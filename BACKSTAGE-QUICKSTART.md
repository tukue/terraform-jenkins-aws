# Quick Start: Backstage

This repository already includes a Backstage app. The KISS path is to use the checked-in `backstage-app` and the root `Makefile` targets.

Do not start by creating a new Backstage app. Start by running the one that is already configured for this repo.

## Supported Local Paths

There are two simple local options:

- `make local-up`
  Uses Docker and starts the local stack, including Backstage, Grafana, Prometheus, and Vault.
- `make backstage-start`
  Runs the checked-in `backstage-app` directly on the host for frontend and backend development.

## Prerequisites

- Node.js `22` or `24`
- Yarn `4`
- Docker, if you want the container-based local stack
- optional `GITHUB_TOKEN` if you want GitHub-backed scaffolder or integration features

## Fastest Path

From the repository root:

```bash
make backstage-validate
make local-up
make local-health
```

Then open:

- `http://localhost:7000` for the Backstage UI
- `http://localhost:7007` for the Backstage backend

The UI now opens on a dedicated `Platform Home` page instead of dropping straight into the raw catalog index.

## Host Development Path

If you want to run Backstage without Docker:

```bash
make backstage-install
make backstage-start
```

This starts the checked-in app under `backstage-app/` and sets `REPO_ROOT` so the catalog can load local repo files.

## What Should Work

The local Backstage setup should load:

- root `catalog-info.yaml`
- `.backstage/system-and-components.yaml`
- `.backstage/groups-and-users.yaml`
- `templates/create-jenkins-ec2-template.yaml`
- `templates/create-customer-ecs-runtime-template.yaml`
- `templates/create-standard-service-template.yaml`

In the UI, the simplest smoke test is:

1. open `Platform Home`
2. confirm the product cards and golden-path guidance load
3. open the catalog
4. confirm the platform system and components load
5. open the `Create` page
6. confirm the Jenkins, customer ECS runtime, and standard service templates appear

## KISS Rules

To keep the local Backstage flow simple in this repository:

- use `backstage-app/` as the primary local app
- use the root `Makefile` targets as the entry point
- treat `backstage-local-test/` as legacy support material, not the main path
- prefer local file catalog locations over remote registration while iterating

## Troubleshooting

### Catalog does not load

Run:

```bash
make backstage-validate
```

This validates the local catalog and template YAML files without requiring a full Backstage startup.

### Host start cannot find repo files

Use the root `Makefile` target instead of running `yarn start` manually:

```bash
make backstage-start
```

That ensures `REPO_ROOT` is set correctly.

### Docker stack is unhealthy

Check:

```bash
make local-logs
make local-ps
```

### GitHub integration features fail

Set `GITHUB_TOKEN` before starting Backstage. Basic local catalog browsing does not require it, but scaffolder publishing and some integration flows do.

## Related Docs

- [Backstage App README](./backstage-app/README.md)
- [Local Platform Quickstart](./docs/local-platform-quickstart.md)
- [Getting Started](./docs/getting-started.md)
