# Vault Local Test

This directory is a minimal Terraform harness for testing the Vault integration without the AWS backend or the Jenkins stack.

## Run

```bash
cp terraform.tfvars.example terraform.tfvars
set TF_CLI_CONFIG_FILE=terraform.rc
terraform init
terraform plan -var-file=terraform.tfvars
```

## Expected secret

The example plan expects a KV v2 secret at:

`secret/jenkins/platform/test`

with a key named:

`value`
