# ECR Cross-Region Replication Portfolio Reference

This account-baseline example replicates repositories with a selected prefix from the source ECR registry to a standby Region.

## Scope

- One ECR registry replication rule
- Cross-Region replication within one AWS account
- Prefix filtering so only platform application repositories are copied

## Important

ECR replication configuration is a singleton per source registry. Apply this example once from a dedicated account-baseline Terraform state; do not place it in application, environment, or EKS cluster states.

## Demonstration

1. Copy `terraform.tfvars.example` to a local `terraform.tfvars`.
2. Apply in a sandbox account.
3. Push an immutable image to an ECR repository matching `repository_prefix`.
4. Verify the image digest appears in the destination Region before deploying it to the standby EKS cluster.
