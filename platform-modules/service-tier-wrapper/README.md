# Service Tier Wrapper Module

This module wraps `platform-modules/customer-ecs-runtime` with a smaller input surface and opinionated sizing tiers.

## Purpose

Use this module when you want a standard ECS service shape without exposing every runtime setting directly to the caller.

It converts a small set of product-style inputs into:

- CPU and memory sizing
- desired task count
- WAF rate limit defaults
- standard tagging for the wrapped service

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
