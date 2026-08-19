# Customer ECS Runtime Example

This example shows how to provision a customer-specific ECS runtime using the `customer-ecs-runtime` platform module.

If you need a standard service shape rather than a custom customer runtime, prefer the [service-tier-wrapper example](../service-tier-wrapper/README.md). That is the more productized consumer path.

## What this example is for

- A dedicated runtime for a customer tenant
- A starting point for Backstage self-service provisioning
- A reference implementation for ECS-based onboarding
- A landing-zone aware runtime that can resolve network defaults from AWS SSM
- Built-in autoscaling, HTTPS redirect support, and WAF defaults for new customer environments
- A dedicated ECR repository for scanned application images
- Environment-specific Terraform files for `dev`, `qa`, and `prod`
- A provisioning workflow that plans and applies each environment
- A delivery workflow that builds, scans, pushes, and deploys image updates to a selected environment
- Baseline policy checks with `terraform fmt -check`, `terraform validate`, and TFLint

## When Not To Use This Example

Do not start here when the service fits the platform's standard tiers and does not need custom ECS runtime decisions.

Use this example only when you explicitly need:

- lower-level runtime control
- custom sizing outside the platform tiers
- direct runtime engineering beyond the supported service wrapper contract

## Folder layout

- `provider.tf` - AWS provider configuration
- `main.tf` - Calls the shared customer ECS runtime module
- `outputs.tf` - Useful runtime outputs
- `catalog-info.yaml` - Backstage catalog entry for the generated runtime
- `backend-config-*.hcl` - Shared remote state configuration per environment
- `terraform.*.tfvars` - Environment-specific Terraform variables
- `terraform.tfvars.example` - Example values including region and account
- The generated repository also includes `.github/workflows/` for provisioning and image deployment

## How to use

1. Copy this example into a customer-specific folder.
2. Replace the placeholder values with the customer details.
3. Run the `dev` provisioning workflow first.
4. Promote through `qa` and `prod` after validation.

## Recommended inputs

- AWS region selected in Backstage
- AWS account ID selected in Backstage
- Tenant name
- Container image
- Optional DNS name
- Optional ACM certificate ARN

The example assumes the regional landing zone already provides:

- VPC ID
- Public subnet IDs
- Private subnet IDs

Autoscaling defaults are standardized by environment in the shared module:

- `dev`: smaller range for lower-cost testing
- `qa`: moderate range for validation traffic
- `prod`: more headroom and more conservative scale-in behavior

Set the autoscaling variables only when you need to override those defaults.

Use the generated delivery workflows to keep the runtime and app image promotion flow aligned across environments.
