# Vault Local Test

This directory is a minimal Terraform harness for testing the Vault integration without the AWS backend or the Jenkins stack.

## Run

```bash
export TF_VAR_vault_address="http://127.0.0.1:8200"
export TF_VAR_vault_token="root"
export TF_VAR_vault_kv_mount="secret"
export TF_VAR_vault_secret_path="jenkins/platform/test"
export TF_VAR_vault_secret_key="value"
terraform init
terraform plan
```

## Expected secret

The plan expects a KV v2 secret at:

`secret/jenkins/platform/test`

with a key named:

`value`
