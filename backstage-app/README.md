# Backstage App

This is the primary local Backstage app for this repository.

Run it from the repository root so the required environment is set consistently:

```bash
make backstage-install
make backstage-start
```

For the full local stack, use:

```bash
make local-up
make local-health
```

The root `Makefile` sets `REPO_ROOT` so the catalog can load this repository's local files and templates.
