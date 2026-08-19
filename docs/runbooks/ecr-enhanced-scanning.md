# ECR Enhanced Scanning Runbook

Use this runbook once for each AWS account and Region that stores platform application images. Do not add this configuration to reusable EKS, application, or environment Terraform states: Amazon ECR registry scanning is a singleton setting for the account and Region.

## Prerequisites

- An approved AWS account and Region for the platform registry
- IAM permission to configure the ECR private registry
- Approval for Amazon Inspector Enhanced scanning charges

## Configure the account baseline

Manage the setting from the centralized account-baseline Terraform state:

```hcl
resource "aws_ecr_registry_scanning_configuration" "platform" {
  scan_type = "ENHANCED"

  rule {
    scan_frequency = "CONTINUOUS_SCAN"

    repository_filter {
      filter      = "*"
      filter_type = "WILDCARD"
    }
  }
}
```

Apply the account-baseline Terraform state, then verify the registry configuration:

```bash
aws ecr get-registry-scanning-configuration --region <region>
```

## Verify and operate

- Confirm `scanType` is `ENHANCED` and the wildcard rule uses `CONTINUOUS_SCAN`.
- Review Amazon Inspector findings and EventBridge notifications using the account security process.
- Keep the pre-push Trivy gate enabled; ECR scanning detects new vulnerabilities in images that were clean when released.
