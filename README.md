# Platform-As-Product Repository

This repository is positioned as a platform engineering product portfolio, not a loose Terraform codebase.

It packages infrastructure into reusable platform capabilities with:

- productized Terraform modules
- Backstage self-service templates
- clear consumer-facing documentation
- environment-aware delivery patterns
- governance, support, and operational guidance

## Product Focus

The repository currently centers on two platform product tracks:

1. `Jenkins on AWS` for standardized CI/CD infrastructure
2. `Customer ECS Runtime` for repeatable tenant or service runtime delivery

The value is not just the provisioning logic. The value is the product surface around it:

- named capabilities that teams can understand and request
- golden paths that reduce one-off delivery work
- published boundaries, defaults, and ownership
- documentation that explains how the platform is consumed and supported

## Consumer Journeys

The main journeys this repository supports are:

1. Discover the platform products, their boundaries, and their operating model.
2. Review the Backstage self-service flow and scaffolder templates.
3. Inspect the reusable Terraform modules and examples behind the product surface.
4. Review runbooks, support expectations, and implementation maturity.

## Start Here

Use these as the main entry points:

- [Internal Developer Platform View](docs/internal-developer-platform.md)
- [Platform-as-a-Product Implementation Status](docs/platform-as-product-implementation-status.md)
- [Platform-as-Product Readiness](docs/platform-as-product-readiness.md)
- [Jenkins on AWS Platform Product](docs/platform-product-jenkins.md)
- [Customer ECS Runtime Platform Product](docs/platform-product-ecs-runtime.md)
- [Platform Golden Paths](docs/platform-golden-paths.md)
- [Platform Service Tiers](docs/platform-service-tiers.md)
- [Platform Support Model](docs/platform-support-model.md)
- [Platform Governance Model](docs/platform-governance-model.md)
- [Platform Versioning and Deprecation](docs/platform-versioning-and-deprecation.md)

## Platform Surface

The strongest platform-product signals in this repository are:

### Product Definition

- explicit product-track docs for Jenkins and ECS runtime
- platform operating model, governance model, and support model
- service tiers and lifecycle expectations

### Self-Service Experience

- Backstage catalog registration in [catalog-info.yaml](catalog-info.yaml)
- scaffolder templates in [templates/README.md](templates/README.md)
- local portal setup in [BACKSTAGE-QUICKSTART.md](BACKSTAGE-QUICKSTART.md)

### Reusable Implementation

- reusable building blocks in [platform-modules](platform-modules)
- example consumption patterns in [platform-examples](platform-examples)
- environment-aware Terraform configuration for `dev`, `qa`, and `prod`

### Operational Readiness

- local platform setup in [docs/local-platform-quickstart.md](docs/local-platform-quickstart.md)
- observability support in [observability-service/README.md](observability-service/README.md)
- secret workflow support in [vault-service/README.md](vault-service/README.md)
- runbooks such as [docs/runbooks/scaling-jenkins.md](docs/runbooks/scaling-jenkins.md)

## Repository Structure

| Path | Purpose |
|---|---|
| `docs/` | Platform-product docs, architecture, operating model, and runbooks |
| `platform-modules/` | Reusable platform building blocks |
| `platform-examples/` | Example implementations of platform patterns |
| `templates/` | Backstage scaffolder templates for self-service |
| `backstage-app/` | Local Backstage app assets |
| `backstage/` | Backstage deployment-oriented assets |
| `jenkins/` | Jenkins product implementation assets |
| `observability-service/` | Local observability support stack |
| `vault-service/` | Local Vault support for secret workflow testing |

## Recommended Review Flow

If the goal is to evaluate this repo as a platform-as-product example, review it in this order:

1. Read the platform-positioning documents.
2. Read the product-track documents.
3. Review the Backstage catalog and templates.
4. Inspect the reusable Terraform modules and examples.
5. Review the operating model, support model, and runbooks.

## Positioning

This repository is strongest when presented as:

- a platform-as-product transformation example
- a platform engineering portfolio for standardization and enablement
- a Backstage plus Terraform self-service reference implementation
- a consulting-friendly example of turning repeated infra work into products

It should not be presented as:

- a fully production-hardened internal developer platform
- a complete enterprise governance implementation
- a finished multi-runtime platform with mature automation in every path

## Contribution Standard

Changes in this repository should improve at least one of these outcomes:

- stronger product clarity
- better self-service usability
- more reusable infrastructure patterns
- clearer ownership, support, and governance

For contribution expectations, see [CONTRIBUTING.md](CONTRIBUTING.md).
