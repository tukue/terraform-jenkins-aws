# Service Tier Wrapper Example

This example shows the default product-facing Terraform path for a standard ECS service.

It uses `platform-modules/service-tier-wrapper` rather than the lower-level `customer-ecs-runtime` module so the caller works with a smaller, opinionated contract.

## What this example is for

- standard service onboarding
- Backstage and self-service flows that should stay on supported platform tiers
- teams that need a service runtime without choosing raw ECS task sizing
- a delivery path where the platform owns the runtime defaults and the consumer owns the service-specific inputs

## What the caller controls

- service name
- environment
- tier
- container image
- optional DNS settings
- optional task environment variables and secrets

## What the platform controls

- ECS CPU and memory sizing derived from the selected tier
- desired task count derived from the selected tier
- WAF defaults derived from the selected tier
- runtime wiring delegated to the shared customer ECS runtime module

## Files

- `provider.tf` - AWS provider configuration
- `main.tf` - Calls the service tier wrapper module
- `variables.tf` - Small consumer input contract
- `outputs.tf` - Product, runtime, and deployment summaries
- `terraform.tfvars.example` - Example values for a standard service

## How to use

1. Copy `terraform.tfvars.example` to `terraform.tfvars`.
2. Set the service identity, environment, tier, and container image.
3. Run `terraform init`.
4. Run `terraform plan`.
5. Apply after review.

## When to use the lower-level runtime example instead

Use [customer-ecs-runtime](../customer-ecs-runtime/README.md) instead when the platform has approved a non-standard runtime shape that does not fit the supported tier model.
