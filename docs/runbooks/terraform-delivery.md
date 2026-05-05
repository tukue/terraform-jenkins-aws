# Terraform Delivery Runbook

Use this runbook for routine platform infrastructure changes.

## Local quality gate

Run the same checks before opening a pull request:

```bash
make quality
```

For plan policy checks, create a JSON plan and pass it to Conftest:

```bash
terraform plan -var-file=terraform.dev.tfvars -out=tfplan
terraform show -json tfplan > tfplan.json
make policy TF_PLAN=tfplan.json
```

## Pull request expectations

- Keep changes scoped to one platform capability or module.
- Update module documentation, Backstage catalog metadata, and examples when interfaces change.
- Include rollback notes for production-impacting changes.
- Treat Checkov, tfsec, TFLint, and OPA findings as blocking unless the exception is documented and approved.

## Apply workflow

1. Merge only after the quality gate and environment plans pass.
2. Use the `Jenkins Platform Delivery` workflow with `action=apply`.
3. Apply dev first, then qa, then prod.
4. Confirm CloudWatch alarms, Jenkins health, and affected service endpoints after each apply.

## Rollback workflow

1. Revert the change or restore the previous module version.
2. Run `terraform plan` for the affected environment.
3. Apply through the same workflow after approval.
4. Capture the incident notes and follow-up tasks in the pull request or issue.
