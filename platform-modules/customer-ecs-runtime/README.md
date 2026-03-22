# Customer ECS Runtime Module

This module provisions a customer-specific ECS runtime on AWS.

## What it creates

- ECS cluster
- Fargate task definition
- ECS service
- Application Load Balancer
- Target group and listeners
- Security groups
- CloudWatch logs
- AWS WAF web ACL with managed application security rules
- Optional Route 53 alias record
- Region and account metadata for multi-region provisioning

## Intended use

Use this module when a customer needs a dedicated runtime for a microservice-based application and ECS is the chosen platform.

If `vpc_id` and subnet lists are omitted, the module resolves them from SSM parameters in the regional landing zone:

- `/platform/<region>/<network_profile>/vpc-id`
- `/platform/<region>/<network_profile>/public-subnet-ids`
- `/platform/<region>/<network_profile>/private-subnet-ids`

## Example usage

```hcl
module "customer_runtime" {
  source = "../platform-modules/customer-ecs-runtime"

  customer_name    = "acme"
  tenant_name      = "acme-store"
  environment      = "prod"
  aws_region       = "eu-north-1"
  aws_account_id   = "123456789012"
  container_image  = "123456789012.dkr.ecr.eu-north-1.amazonaws.com/acme-api:latest"

  tags = {
    Owner = "platform-team"
  }
}
```

## Notes

- This module assumes Fargate
- The default `network_profile` is `standard`
- VPC and subnet identifiers are resolved from the landing zone by default
- Public access is handled through the ALB
- The task security group only allows traffic from the ALB security group
- The module can be extended with autoscaling, WAF, or private-only endpoints later
- WAF is enabled by default and protects the ALB using AWS managed rule groups plus rate limiting
