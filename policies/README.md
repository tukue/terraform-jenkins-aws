# Policy as Code (PaC)

This directory contains Open Policy Agent (OPA) policies written in Rego to enforce governance, security, and cost-management across the platform's infrastructure.

## Policy Categories

### 1. Tagging Standards (`terraform/tags.rego`)
Enforces mandatory tags on all managed resources to ensure accountability and organized resource management.
- **Required Tags:** `Environment`, `Project`, `Owner`.
- **Allowed Environments:** `dev`, `qa`, `prod`.

### 2. Networking and Security (`terraform/networking.rego`)
Enforces security best practices for VPCs and Security Groups.
- **Sensitive Ports:** Blocks ingress from `0.0.0.0/0` on ports like 22 (SSH), 5432 (PostgreSQL), etc.
- **Security Group Descriptions:** Rejects default "Managed by Terraform" descriptions in favor of descriptive ones.

### 3. Cost and Best Practices (`terraform/cost.rego`)
Enforces cost-effective choices and basic security hygiene.
- **Instance Types:** Restricts `dev` environment instances to `t3.micro`, `t3.small`, and `t3.medium`.
- **Encryption:** Mandates encrypted root volumes for all EC2 instances.

## How to Test Policies Locally

You can use `conftest` or `opa` to test these policies against a Terraform plan JSON.

### 1. Generate Terraform Plan
```bash
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json
```

### 2. Run Policy Check with Conftest
```bash
conftest test tfplan.json --policy policies/terraform
```

### 3. Run Policy Check with OPA
```bash
opa eval --data policies/terraform --input tfplan.json "data.terraform.tags.deny"
```

## Integrating into CI/CD

These policies are designed to be part of the pull request validation workflow. A failure in any policy check should block the infrastructure change from being applied.

## Future Policies

- S3 bucket versioning and encryption requirements.
- IAM least privilege (blocking `*` permissions).
- Multi-AZ requirements for production environments.
