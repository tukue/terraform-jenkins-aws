# ADR-003: Environment Separation via tfvars and Backend Configs

**Status:** Accepted  
**Date:** 2024-01-15  
**Decider:** Platform Engineering Team  

## Context

The platform needs to support multiple environments (development, QA, production) with:
- Independent lifecycle management (changes promoted through environments)
- Varying resource configurations (instance sizes, feature flags)
- Blast radius containment (issues in dev must not affect production)
- Clear promotion paths

Options considered: Terraform workspaces, separate tfvars + backend configs, Terragrunt, separate repositories.

## Decision

Use environment-specific `terraform.<env>.tfvars` files and `backend-config-<env>.hcl` files with a single Terraform root module. Environments are isolated by state key paths within the same S3 bucket.

## Structure

```
terraform.dev.tfvars      # Dev-specific variable values
terraform.qa.tfvars       # QA-specific variable values
terraform.prod.tfvars     # Production-specific variable values
backend-config-dev.hcl    # Dev backend: key = terraform/dev/terraform.tfstate
backend-config-qa.hcl     # QA backend:  key = terraform/qa/terraform.tfstate
backend-config-prod.hcl   # Prod backend: key = terraform/prod/terraform.tfstate
```

Usage:
```bash
terraform init -backend-config=backend-config-dev.hcl
terraform plan -var-file=terraform.dev.tfvars -out=tfplan
terraform apply tfplan
```

## Trade-offs

- **vs. Terraform workspaces**: Workspaces share the same backend configuration and state bucket. State key naming via separate backend configs achieves the same isolation with more explicit configuration. Workspaces add cognitive overhead with their default workspace behavior.
- **vs. Terragrunt**: Terragrunt would provide native environment directory structure, dependency management, and DRY configuration. Adding it is a future enhancement (see ADR-005). Current approach keeps the toolchain minimal.
- **vs. Separate repositories**: Separate repos per environment provide the strongest isolation but introduce drift and duplication. A monorepo with shared modules and environment-specific configs balances consistency with isolation.

## Consequences

- All three environments share the same S3 bucket and DynamoDB table. A future improvement would be separate buckets per environment or per AWS account for stronger isolation.
- Environment promotion is manual (apply dev, then qa, then prod). CI/CD automation with approval gates is planned.
- Variable files contain environment-specific values like CIDR blocks and instance types — they must be kept in sync manually.
