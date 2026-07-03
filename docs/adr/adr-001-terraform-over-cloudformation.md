# ADR-001: Use Terraform over CloudFormation for IaC

**Status:** Accepted  
**Date:** 2024-01-15  
**Decider:** Platform Engineering Team  

## Context

The platform requires Infrastructure-as-Code tooling to provision and manage AWS resources. The two dominant options in the AWS ecosystem are Terraform (HashiCorp) and AWS CloudFormation/CDK.

Key evaluation criteria:
- Multi-cloud and multi-provider support (AWS, Kubernetes, Helm, etc.)
- Community module ecosystem for reusable patterns
- Policy-as-code integration for shift-left compliance
- State management and team collaboration
- Tooling ecosystem for validation and security scanning

## Decision

We will use Terraform as the IaC tool.

## Rationale

| Factor | Terraform | CloudFormation |
|--------|-----------|----------------|
| Provider support | 200+ providers including AWS, Azure, GCP, K8s, Helm | AWS-only |
| Community modules | 20,000+ in Terraform Registry | N/A |
| Policy-as-code | OPA/Conftest integrates natively with plan JSON | No equivalent |
| State management | S3 + DynamoDB (industry standard) | Managed (simpler but less control) |
| Validation tooling | TFLint, tfsec, Checkov, Infracost | cfn-lint, cfn-nag |
| Multi-cloud | Native | Not possible |

## Trade-offs

- **State complexity**: Remote state with S3 + DynamoDB adds operational overhead vs. CloudFormation's fully managed state. Mitigated by state versioning, locking, and KMS encryption.
- **AWS feature lag**: New AWS services typically ship to CloudFormation first. Acceptable as this platform uses well-established services.
- **Provider versioning**: Terraform provider versions must be pinned and managed explicitly (handled via `.terraform.lock.hcl`).

## Consequences

- All infrastructure must pass through `terraform fmt`, `tflint`, `tfsec`, `checkov`, and OPA/Conftest before apply
- State backend (S3 + DynamoDB) must be provisioned before any workspace
- Module versioning follows semantic versioning with changelogs
