# Getting Started

Use this document to choose the right entry point into the platform product paths in this repository.

This repository currently presents two main platform tracks:

- `Jenkins on AWS`
- `Customer ECS Runtime`

If you are reviewing the repo as a platform product, start with the product docs first and then move into the implementation path you care about.

## Start Here

Read these documents in order:

1. [Platform-as-Product Readiness Plan](./platform-as-product-readiness.md)
2. [Platform Golden Paths](./platform-golden-paths.md)
3. [Jenkins on AWS Platform Product](./platform-product-jenkins.md) or [Customer ECS Runtime Platform Product](./platform-product-ecs-runtime.md)

## Choose Your Path

### Path 1: Local Platform Evaluation

Use this path when you want to inspect the platform experience locally before provisioning AWS resources.

Start here:

- [Local Platform Quickstart](./local-platform-quickstart.md)
- [Internal Developer Platform View](./internal-developer-platform.md)
- [Templates Overview](../templates/README.md)

This path is best for:

- portfolio review
- local workflow validation
- understanding how the platform is packaged

### Path 2: Jenkins on AWS

Use this path when you want to provision the Jenkins infrastructure baseline in AWS.

Start here:

1. Review [Jenkins on AWS Platform Product](./platform-product-jenkins.md).
2. Review [DEPLOYMENT-GUIDE.md](../DEPLOYMENT-GUIDE.md).
3. Choose the target environment:
   - `terraform.dev.tfvars`
   - `terraform.qa.tfvars`
   - `terraform.prod.tfvars`
4. Initialize Terraform with the matching backend config:

```bash
terraform init -backend-config="backend-config-dev.hcl"
```

5. Plan the selected environment:

```bash
terraform plan -var-file="terraform.dev.tfvars"
```

6. Apply after review:

```bash
terraform apply -var-file="terraform.dev.tfvars" -var="bucket_name=jenkins-tfstate-platform"
```

7. Use [Scaling Jenkins Runbook](./runbooks/scaling-jenkins.md) and [Architecture Documentation](./architecture.md) for follow-through.

### Path 3: Customer ECS Runtime

Use this path when you want to review or extend the reusable ECS runtime pattern.

Start here:

1. Review [Customer ECS Runtime Platform Product](./platform-product-ecs-runtime.md).
2. Review [Multi-Tenant Customer Runtime Design](./multi-tenant-customer-runtime-design.md).
3. Review [Multi-Tenant ECS Provisioning Implementation](./multi-tenant-ecs-provisioning-implementation.md).
4. Inspect the reusable baseline in [platform-examples/customer-ecs-runtime/README.md](../platform-examples/customer-ecs-runtime/README.md) and `platform-modules/customer-ecs-runtime/`.

This path is best for:

- understanding the ECS runtime product boundary
- reviewing the multi-environment runtime model
- extending the reusable runtime baseline

## Prerequisites

For AWS-backed work, you should have:

- AWS account access with appropriate IAM permissions
- Terraform
- Git
- any environment-specific variable values required by the selected product path

For local evaluation, use:

- `make local-up`
- `make local-health`

## Optional: Local Vault Test

If you want to validate the local Vault integration during Terraform planning, set the Vault inputs in your shell:

```bash
export TF_VAR_enable_vault_integration=true
export TF_VAR_vault_address="http://127.0.0.1:8200"
export TF_VAR_vault_token="root"
export TF_VAR_vault_kv_mount="secret"
export TF_VAR_vault_secret_path="jenkins/platform/test"
export TF_VAR_vault_secret_key="value"
terraform plan -var-file="terraform.dev.tfvars"
```

Then create the test secret:

```bash
vault kv put secret/jenkins/platform/test value="hello-from-vault"
```

If the secret exists in the local Vault server, Terraform exposes it through the sensitive output `vault_test_secret_value`.

## Related Docs

- [Platform Operating Model](./platform-operating-model.md)
- [Platform Governance Model](./platform-governance-model.md)
- [Platform Support Model](./platform-support-model.md)
- [Best Practices](./best-practices.md)
