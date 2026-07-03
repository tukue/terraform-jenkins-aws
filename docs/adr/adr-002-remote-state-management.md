# ADR-002: Remote State with S3 and DynamoDB

**Status:** Accepted  
**Date:** 2024-01-15  
**Decider:** Platform Engineering Team  

## Context

Terraform state files contain the mapping between configuration and real-world resources. They are sensitive (may contain secrets, resource ARNs, etc.) and must be:
- Shared across team members (not stored locally)
- Locked during operations to prevent concurrent modification
- Versioned for disaster recovery and audit trails
- Encrypted at rest

Options considered: S3 + DynamoDB, Terraform Cloud, Consul backend, local state.

## Decision

Use S3 as the remote state backend with DynamoDB for state locking.

## Configuration

```hcl
terraform {
  backend "s3" {
    bucket         = "jenkins-tfstate-platform"
    key            = "terraform/${var.environment}/terraform.tfstate"
    region         = "eu-north-1"
    encrypt        = true
    dynamodb_table = "jenkins-terraform-locks"
  }
}
```

The backend infrastructure (S3 bucket + DynamoDB table) is defined in `s3.tf` with:
- KMS-CMEK encryption for both S3 and DynamoDB
- S3 versioning enabled for state recovery
- Public access blocks on all state buckets
- S3 access logs delivered to a separate logging bucket
- DynamoDB point-in-time recovery enabled
- `prevent_destroy` lifecycle to prevent accidental deletion
- Non-current version expiration after 90 days

## Trade-offs

- **vs. Terraform Cloud**: Terraform Cloud provides a managed state backend with built-in locking, remote operations, and VCS integration. We chose self-managed S3 + DynamoDB to avoid vendor lock-in and because the team was already familiar with AWS. Terraform Cloud remains an option for future consideration.
- **vs. Local state**: Local state is unacceptable for team collaboration. S3 backend is the baseline for any team environment.
- **vs. Consul**: Consul requires maintaining a Consul cluster. S3 + DynamoDB is serverless and requires no additional infrastructure.

## Consequences

- All team members and CI/CD pipelines must have AWS credentials with S3 and DynamoDB access
- State bucket must exist before any `terraform init` can succeed — bootstrap is required
- Sensitive output values are stored in the state file; access to the state bucket must be restricted via IAM
- State file size grows over time; large states may slow down operations (mitigated by splitting into workspaces if needed)
