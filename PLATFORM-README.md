# Platform Product Overview

This repository represents a platform-as-product implementation on AWS built around Backstage, Terraform, and reusable operating guidance.

The focus is not "how to provision some infrastructure." The focus is "how to turn repeated infrastructure demand into platform products that teams can understand, adopt, and consume."

## What The Platform Product Includes

The current platform surface is built from four layers:

1. Product tracks for Jenkins infrastructure and ECS runtime delivery
2. Self-service entry points through Backstage catalog entities and templates
3. Reusable Terraform modules and example consumption patterns
4. Governance, support, versioning, and runbook documentation

## Product Tracks

### Jenkins on AWS

This track provides a standardized Jenkins infrastructure path for teams that need a repeatable CI/CD foundation on AWS.

Primary reference:

- [docs/platform-product-jenkins.md](docs/platform-product-jenkins.md)

### Customer ECS Runtime

This track provides a repeatable ECS runtime path for teams that need a standardized customer or service runtime baseline on AWS.

Primary reference:

- [docs/platform-product-ecs-runtime.md](docs/platform-product-ecs-runtime.md)

## Consumer Experience

The intended consumer flow is:

1. Discover the platform and ownership model in Backstage.
2. Select a supported golden path or product track.
3. Use documented templates, examples, and environment inputs.
4. Operate within published standards, support boundaries, and lifecycle guidance.

This makes the repository easier to understand as a platform product instead of a set of raw implementation files.

## Key Entry Points

Start with these documents:

- [README.md](README.md)
- [docs/internal-developer-platform.md](docs/internal-developer-platform.md)
- [docs/platform-as-product-implementation-status.md](docs/platform-as-product-implementation-status.md)
- [docs/platform-as-product-readiness.md](docs/platform-as-product-readiness.md)
- [docs/platform-golden-paths.md](docs/platform-golden-paths.md)
- [docs/platform-operating-model.md](docs/platform-operating-model.md)
- [docs/platform-support-model.md](docs/platform-support-model.md)
- [docs/platform-governance-model.md](docs/platform-governance-model.md)

## Self-Service and Catalog

The self-service surface is represented by:

- [catalog-info.yaml](catalog-info.yaml)
- [templates/README.md](templates/README.md)
- [BACKSTAGE-QUICKSTART.md](BACKSTAGE-QUICKSTART.md)

These assets show how platform capabilities become discoverable and consumable rather than remaining hidden in infrastructure code.

## Implementation Foundation

The product foundation behind the user-facing experience lives in:

- [platform-modules](platform-modules)
- [platform-examples](platform-examples)
- environment-specific Terraform inputs for `dev`, `qa`, and `prod`
- supporting docs, runbooks, and local platform tooling

## Positioning Guidance

Use this repository to demonstrate:

- platform product thinking
- self-service enablement
- reusable infrastructure design
- explicit support and governance boundaries

Avoid presenting it as:

- a finished enterprise platform
- a fully managed Backstage deployment
- a complete production operations environment
