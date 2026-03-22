# Platform Examples

This directory contains runnable examples for the platform tracks in this repository.

## Examples

### Jenkins Environment Examples

- `dev-environment.tfvars`
- `qa-environment.tfvars`
- `prod-environment.tfvars`

These are useful when you want to deploy the Jenkins platform with repeatable settings.

### Customer ECS Runtime

- `customer-ecs-runtime/`

This example shows the landing-zone aware ECS path where the customer selects AWS account and AWS region, and the platform resolves the rest.

## How To Use

1. Choose the example that matches your track.
2. Copy the example variables file.
3. Update the values for your environment.
4. Run `terraform init`, `terraform plan`, and `terraform apply`.

## Related Docs

- [Platform README](../README.md)
- [Customer ECS Runtime Module](../platform-modules/customer-ecs-runtime/README.md)
