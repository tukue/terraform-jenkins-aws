# Platform Engineering Portfolio

This repository is structured as a consulting-style platform engineering profile rather than a loose Terraform codebase.

It demonstrates how to package infrastructure into a usable platform product with:

- reusable Terraform modules
- self-service Backstage templates
- environment-aware delivery patterns
- platform documentation and runbooks
- baseline governance, security, and observability

## What This Repo Shows

The repository currently showcases two platform product tracks:

1. Jenkins platform on AWS for standardized CI/CD infrastructure
2. ECS customer runtime platform for repeatable SaaS environment delivery

Both tracks are presented as productized platform capabilities instead of one-off infrastructure work.

## Why This Matters

The consulting value of this repository is in the operating model it suggests:

- turn repeated infrastructure demand into reusable platform services
- reduce delivery variance with standard modules and templates
- give teams a self-service entry point through Backstage
- make ownership, guardrails, and supportability visible
- document the platform as something teams consume, not just something engineers build

## Priority Order

These are the most important elements in the repo, ordered by portfolio value.

### Priority 1: Productized Platform Story

This is the highest-value layer because it changes the repo from an infrastructure sample into a platform engineering profile.

- clear platform boundaries
- named product tracks
- reusable service patterns
- consumer-facing docs and templates

Read first:

- [Internal Developer Platform View](docs/internal-developer-platform.md)
- [Platform-as-a-Product Implementation Status](docs/platform-as-product-implementation-status.md)
- [Platform-as-Product Readiness Plan](docs/platform-as-product-readiness.md)
- [Changelog](CHANGELOG.md)
- [Platform Golden Paths](docs/platform-golden-paths.md)
- [Platform Governance Model](docs/platform-governance-model.md)
- [Platform Support Model](docs/platform-support-model.md)
- [Platform Service Tiers](docs/platform-service-tiers.md)
- [Platform Versioning and Deprecation](docs/platform-versioning-and-deprecation.md)

### Priority 2: Self-Service Experience

This is the strongest proof that the platform is consumable, not just operable.

- Backstage catalog registration
- scaffolder templates
- standard input model for new services and runtimes

Review:

- [Templates Overview](templates/README.md)
- [Backstage Quick Start](BACKSTAGE-QUICKSTART.md)

### Priority 3: Reusable Infrastructure Foundation

This shows the platform has real implementation depth behind the product surface.

- Terraform modules
- environment-specific configuration
- AWS networking, load balancing, security, and runtime building blocks

Review:

- [platform-modules](platform-modules)
- [platform-examples](platform-examples)

### Priority 4: Operational Readiness

This layer shows the platform is designed to be supported, not only provisioned.

- runbooks
- observability assets
- Vault and local platform support components

Review:

- [Local Platform Quickstart](docs/local-platform-quickstart.md)
- [Observability Service](observability-service/README.md)
- [Vault Service](vault-service/README.md)

## Repo Structure

| Path | Purpose |
|---|---|
| `platform-modules/` | Reusable platform building blocks |
| `platform-examples/` | Example implementations of platform patterns |
| `templates/` | Backstage scaffolder templates for self-service |
| `backstage-app/` | Backstage application for local platform portal work |
| `backstage/` | Backstage deployment-oriented assets |
| `jenkins/` | Jenkins infrastructure product track |
| `docs/` | Architecture, product, and implementation documentation |
| `observability-service/` | Local observability support stack |
| `vault-service/` | Local Vault support for secret workflow testing |

## Recommended Review Flow

If this repo is being used as a consulting or portfolio profile, review it in this order:

1. Read the platform positioning docs.
2. Read the changelog for the latest platform-facing changes.
3. Review the self-service templates and catalog model.
4. Inspect the Terraform modules and examples.
5. Review the operational docs and local support setup.

## Consulting Profile Positioning

This repository is strongest when positioned as:

- a platform engineering portfolio
- a platform-as-a-product transformation example
- a Backstage plus Terraform self-service reference implementation
- a consulting profile for standardization, enablement, and platform design

It should not be positioned as:

- a finished enterprise platform
- a fully production-hardened Backstage deployment
- a complete multi-runtime internal developer platform

## Priority-Based Improvement Roadmap

The next improvements should be prioritized by consulting impact rather than by technical novelty.

| Priority | Focus Area | Why It Matters |
|---|---|---|
| High | Platform product narrative | Makes the repo legible to clients, hiring managers, and stakeholders |
| High | Self-service golden paths | Proves the platform is consumable and repeatable |
| High | Governance and delivery guardrails | Shows maturity beyond provisioning |
| Medium | Observability and support model | Strengthens operational credibility |
| Medium | Backstage production hardening | Improves realism of the portal story |
| Low | Additional runtime products | Expands scope after the core story is clear |

## Start Here

Use these documents as the primary entry points:

- [Internal Developer Platform View](docs/internal-developer-platform.md)
- [Platform-as-a-Product Implementation Status](docs/platform-as-product-implementation-status.md)
- [Platform-as-Product Readiness Plan](docs/platform-as-product-readiness.md)
- [Changelog](CHANGELOG.md)
- [Platform Golden Paths](docs/platform-golden-paths.md)
- [Jenkins on AWS Platform Product](docs/platform-product-jenkins.md)
- [Customer ECS Runtime Platform Product](docs/platform-product-ecs-runtime.md)
- [Platform Service Tiers](docs/platform-service-tiers.md)
- [Platform Versioning and Deprecation](docs/platform-versioning-and-deprecation.md)
- [Local Platform Quickstart](docs/local-platform-quickstart.md)
- [Backstage Quick Start](BACKSTAGE-QUICKSTART.md)

## Contribution Standard

Changes in this repository should improve one of these outcomes:

- stronger platform product clarity
- better self-service usability
- more reusable infrastructure patterns
- clearer operating model and documentation

For contribution expectations, see [CONTRIBUTING.md](CONTRIBUTING.md).
