# Terraform Delivery Runbook

Use this runbook for routine platform infrastructure changes.

## Local quality gate

Run the same checks before opening a pull request:

```bash
make quality
make validate-live TF_ENV=dev
```

For plan policy checks, create a JSON plan and pass it to Conftest:

```bash
cd live/dev
terraform init -backend-config=backend.hcl
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json
conftest test tfplan.json --policy ../../policies/terraform
```

Use `live/qa` and `live/prod` for higher environments. Do not reuse a root-level plan across environments.

## Remote state bootstrap

The backend foundation lives in `bootstrap/remote-state`. Apply it once before initializing `live/*` roots:

```bash
cd bootstrap/remote-state
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

The bootstrap root manages the S3 state bucket, state access log bucket, KMS key, and DynamoDB lock table.

## Pull request expectations

- Keep changes scoped to one platform capability or module.
- Update module documentation, Backstage catalog metadata, and examples when interfaces change.
- Include rollback notes for production-impacting changes.
- Treat Checkov, tfsec, TFLint, and OPA findings as blocking unless the exception is documented and approved.

## Apply workflow

1. Merge only after the quality gate and environment plans pass.
2. Use the `Jenkins Platform Delivery` workflow with `action=apply` and the target environment.
3. Apply dev first, then qa, then prod.
4. Confirm CloudWatch alarms, Jenkins health, ALB target health, and affected service endpoints after each apply.

The GitHub Environment for each target should provide `AWS_ACCOUNT_ID`, `AWS_ROLE_ARN`, and `JENKINS_PUBLIC_KEY`. Require reviewers on `qa` and `prod`.

## Rollback workflow

1. Revert the change or restore the previous module version.
2. Run `terraform plan` for the affected environment.
3. Apply through the same workflow after approval.
4. Capture the incident notes and follow-up tasks in the pull request or issue.
