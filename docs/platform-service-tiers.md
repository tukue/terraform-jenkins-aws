# Platform Service Tiers

This document defines the service-tier model for the platform product paths in this repository.

## Tier Model

| Tier | Scope | Support Expectation |
|---|---|---|
| Tier 1 | Documentation, examples, and evaluation assets | Best-effort clarification and improvement |
| Tier 2 | Standard Jenkins and ECS golden paths | Supported baseline with documented inputs and defaults |
| Tier 3 | Advanced customization and exceptions | Consumer-owned unless adopted into the baseline |

## Tier 1

Tier 1 includes README-level guidance, architecture docs, examples, and local evaluation assets.

Use Tier 1 to understand and evaluate the platform, not to claim a fully supported runtime path.

## Tier 2

Tier 2 is the main platform product surface.

It includes:

- Jenkins on AWS golden path
- Customer ECS Runtime golden path
- shared modules and templates that back those paths
- documented environment-aware behavior for `dev`, `qa`, and `prod`

## Tier 3

Tier 3 covers advanced customization outside the documented golden path.

If a Tier 3 pattern becomes repeatable and valuable across teams, it can be promoted into Tier 2 later.

## Related Docs

- [Platform Operating Model](./platform-operating-model.md)
- [Platform Support Model](./platform-support-model.md)
- [Platform Governance Model](./platform-governance-model.md)
