# Remote State Bootstrap

This root creates the shared Terraform backend foundation:

- S3 state bucket
- S3 access log bucket
- KMS key and alias
- DynamoDB lock table with point-in-time recovery

Apply this root before initializing any `live/*` environment.

```bash
cd bootstrap/remote-state
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

Keep real `terraform.tfvars` files out of Git. Commit only `terraform.tfvars.example`.
