# Platform Operating Model

This document defines how this repository should be understood as a platform product, not just as infrastructure code.

## Product Intent

The platform provides standardized infrastructure capabilities that application teams can consume through documented paths, reusable modules, and self-service templates.

The current product scope is:

- Jenkins infrastructure on AWS
- customer ECS runtime provisioning on AWS
- Backstage-based service discovery and self-service entry points
- platform standards, docs, and support guidance

The current product does not yet include:

- enterprise-grade approval workflows
- fully production-hardened Backstage operations
- automated drift remediation
- formal multi-runtime expansion beyond the current Jenkins and ECS paths

## Platform Consumers

The primary consumers of this platform are:

- internal platform teams building a reusable delivery foundation
- consulting clients evaluating platform-as-product transformation patterns
- engineering teams needing a standardized Jenkins or ECS runtime path

## Service Tiers

The platform is organized into three service tiers so expectations stay clear.

| Tier | Scope | Expectation |
|---|---|---|
| Tier 1 | Documentation, templates, and examples | Best-effort enablement for evaluation and adoption |
| Tier 2 | Standard Jenkins and ECS golden paths | Reusable default path with documented inputs and operating guidance |
| Tier 3 | Advanced customization | Allowed, but treated as exception work owned by the consuming team |

## Supported Product Paths

### Jenkins Platform Path

Use this path when a team needs:

- a standardized Jenkins runtime on AWS
- environment-aware Terraform delivery
- a known operational baseline for CI workloads

### Customer ECS Runtime Path

Use this path when a team needs:

- a repeatable customer runtime deployment model
- standardized environment promotion across `dev`, `qa`, and `prod`
- a self-service entry point through Backstage scaffolder templates

## Consumer Journey

The intended product journey is:

1. Discover the platform through the README, catalog metadata, and platform docs.
2. Choose the Jenkins or ECS path based on the workload need.
3. Start from the documented template or module path rather than building from scratch.
4. Apply the platform standards and delivery guardrails.
5. Operate the workload with the provided docs, runbooks, and observability assets.

## Ownership Model

The `platform-team` owns:

- reusable modules
- self-service templates
- platform standards
- shared documentation and operating guidance

Consuming teams own:

- workload-specific application configuration
- exceptions beyond the documented golden path
- approvals, credentials, and account access required for their deployments
- operational decisions outside the shared platform baseline

## Support Model

The support model in this repository is intentionally lightweight and portfolio-friendly.

| Area | Support Model |
|---|---|
| Documentation and examples | Best effort |
| Golden path templates | Supported through documented inputs and defaults |
| Advanced exceptions | Case-by-case and consumer-owned |
| Production incident response | Out of scope for this repository showcase |

## Platform Promises

The platform currently promises:

- reusable AWS infrastructure patterns
- clear product boundaries
- a self-service starting point
- visible ownership and standards
- a documented path for evaluation and adoption

The platform does not currently promise:

- enterprise operational coverage
- strict SLA enforcement through automation
- full policy enforcement on every change path
- complete production governance

## Success Measures

This repository should be evaluated on whether it makes the platform product easier to understand and consume.

The main success signals are:

- reduced ambiguity around what the platform offers
- stronger golden-path adoption
- consistent use of templates and modules
- clearer onboarding and review flow for platform consumers

## Related Docs

- [Internal Developer Platform View](./internal-developer-platform.md)
- [Platform-as-a-Product Implementation Status](./platform-as-product-implementation-status.md)
- [Getting Started](./getting-started.md)
- [Platform Standards](../platform-standards/STANDARDS.md)
