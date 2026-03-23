# Customer ECS Runtime Example

This example shows how to provision a customer-specific ECS runtime using the `customer-ecs-runtime` platform module.

## What this example is for

- A dedicated runtime for a customer tenant
- A starting point for Backstage self-service provisioning
- A reference implementation for ECS-based onboarding
- A landing-zone aware runtime that can resolve network defaults from AWS SSM
- Built-in autoscaling, HTTPS redirect support, and WAF defaults for new customer environments
- A dedicated ECR repository for scanned application images
- A generated GitHub Actions workflow that scans before pushing to ECR

## Folder layout

- `provider.tf` - AWS provider configuration
- `main.tf` - Calls the shared customer ECS runtime module
- `outputs.tf` - Useful runtime outputs
- `catalog-info.yaml` - Backstage catalog entry for the generated runtime
- `terraform.tfvars.example` - Example values including region and account

## How to use

1. Copy this example into a customer-specific folder.
2. Replace the placeholder values with the customer details.
3. Run `terraform init`, `terraform plan`, and `terraform apply`.

## Recommended inputs

- AWS region
- AWS account ID
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
