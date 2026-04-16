# Platform Examples

This directory contains runnable examples for the platform tracks in this repository.

## Examples

### Jenkins Platform Delivery Examples

The Jenkins platform now uses the root-level environment files:

- `terraform.dev.tfvars`
- `terraform.qa.tfvars`
- `terraform.prod.tfvars`
- `backend-config-dev.hcl`
- `backend-config-qa.hcl`
- `backend-config-prod.hcl`

These are used by the multi-environment delivery workflow and by local Terraform runs.

### Customer ECS Runtime

- `customer-ecs-runtime/`

This example shows the landing-zone aware ECS path where the customer selects AWS account and AWS region, and the platform resolves the rest.

### Standard Service Tier Wrapper

- `service-tier-wrapper/`

This example shows the default product-facing path for standard service onboarding, where the caller selects a tier and container image instead of managing the full ECS runtime surface.

## How To Use

1. Choose the example that matches your track.
2. Copy the example variables file.
3. Update the values for your environment.
4. Run `terraform init`, `terraform plan`, and `terraform apply`.

## Related Docs

- [Platform README](../README.md)
- [Customer ECS Runtime Module](../platform-modules/customer-ecs-runtime/README.md)
- [Service Tier Wrapper Module](../platform-modules/service-tier-wrapper/README.md)
