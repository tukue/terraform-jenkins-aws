# Service Tier Wrapper Module

This is the default product-facing Terraform surface for standard ECS services in this repository.

It wraps `platform-modules/customer-ecs-runtime` with a smaller, opinionated contract so consumers can request a supported service shape without owning the full runtime configuration surface.

## Product Intent

Use this module when the platform should offer:

- a standard service deployment path
- predictable sizing tiers instead of ad hoc CPU and memory values
- a smaller caller contract for Backstage templates, examples, and onboarding flows
- a clearer separation between supported defaults and exception work

This wrapper intentionally turns low-level ECS decisions into platform defaults:

- CPU and memory sizing
- desired task count
- WAF rate limit defaults
- standard platform tagging
- landing-zone aware network resolution through the underlying runtime module

## Consumer Contract

The intended caller supplies only the inputs that should vary per service:

- service identity
- environment
- service tier
- container image
- optional DNS settings
- optional runtime environment variables and secrets

The caller does not need to choose:

- raw ECS task sizing
- default desired count per tier
- default WAF rate limits
- most lower-level runtime wiring

Use the underlying `customer-ecs-runtime` module directly only when the platform has approved a non-standard runtime shape.

## Supported Tiers

| Tier | CPU | Memory | Desired Count | WAF Rate Limit |
|---|---:|---:|---:|---:|
| `small` | 256 | 512 | 1 | 1000 |
| `med` | 512 | 1024 | 2 | 2000 |
| `large` | 1024 | 2048 | 3 | 5000 |

## Example

```hcl
module "service" {
  source = "../platform-modules/service-tier-wrapper"

  service_name    = "checkout-api"
  tier            = "med"
  environment     = "qa"
  container_image = "123456789012.dkr.ecr.eu-north-1.amazonaws.com/checkout-api:2026-04-15"

  tags = {
    Owner = "platform-team"
  }
}
```

For a runnable consumer example, see [platform-examples/service-tier-wrapper](../../platform-examples/service-tier-wrapper).

## Product Outputs

The wrapper now exposes three output layers so downstream automation can choose the right level of detail:

- `product_contract` for product-level metadata and consumption context
- `runtime_contract` for the remaining caller-controlled runtime inputs
- `deployment_summary` for post-apply handoff, automation, or release workflows

## When To Use The Underlying Module Instead

Use `platform-modules/customer-ecs-runtime` directly when you need:

- custom runtime sizing outside the tier presets
- advanced runtime IAM configuration
- lower-level autoscaling customization
- direct control over more ECS runtime inputs

## Outputs

The wrapper exposes the key outputs needed by most callers:

- cluster and service identity
- customer URL and ALB DNS
- resolved network information
- ECR repository name
- derived sizing summary
- product and deployment summaries for automation and handoff

## Recommended Product Positioning

Treat this module as:

- the default Terraform interface for standard service onboarding
- the module that Backstage and higher-level examples should prefer
- the supported path for teams that do not need custom runtime engineering

Treat the underlying runtime module as:

- the advanced surface for exceptions
- the place where platform engineers make deliberate runtime changes
- a lower-level building block, not the primary consumer entry point
