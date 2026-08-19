# Customer ECS Runtime Module

This module provisions a customer-specific ECS runtime on AWS.

## What it creates

- ECS cluster
- Fargate task definition
- ECS service
- Application Load Balancer
- Target group and listeners
- Security groups
- IAM task and execution roles with scoped secret access options
- CloudWatch logs
- ECS Exec audit logs
- ECR repository for customer images
- AWS WAF web ACL with managed application security rules
- ECS service autoscaling on CPU, memory, and ALB request load
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
- The AWS provider should target the same `aws_account_id` and `aws_region` passed to the module so ECS autoscaling is provisioned in the intended customer environment
- Public access is handled through the ALB
- ALB ingress can be restricted to approved CIDR ranges
- HTTP can redirect to HTTPS automatically when an ACM certificate is provided
- The task security group only allows traffic from the ALB security group
- ECS deployment circuit breaker rolls back failed releases automatically
- Autoscaling is enabled by default so new customer runtimes can scale without extra setup
- WAF is enabled by default and protects the ALB using AWS managed rule groups plus rate limiting
- ECR is created by default so the customer has a dedicated registry for scanned images, and tags are immutable by default
- ECS execution-role secret access can be scoped to explicit Secrets Manager and SSM parameter ARNs
- The application task role can be extended with explicit managed policies or scoped secret and KMS access when the workload needs AWS API access
- Keep `task_secrets` aligned with the execution-role allow-lists so ECS can inject the secret values without broad IAM permissions
