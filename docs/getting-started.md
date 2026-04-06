# Getting Started with terraform-jenkins-aws Platform

## Welcome to the Platform

This is a managed platform project that provides self-service infrastructure provisioning for Jenkins deployments on AWS.

## Quick Start

### 1. Prerequisites
- AWS account access with appropriate IAM permissions
- Terraform >= 1.0
- Git
- SSH key pair for EC2 access

### 2. Clone the Repository
```bash
git clone https://github.com/tukue/terraform-jenkins-aws.git
cd terraform-jenkins-aws
```

### 3. Configure Your Environment
```bash
# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit with your specific values
vim terraform.tfvars
```

### 4. Initialize Terraform
```bash
terraform init -backend-config="backend-config-dev.hcl"
```

### 5. Plan the Infrastructure
```bash
terraform plan -var-file="terraform.dev.tfvars"
```

### 6. Apply Configuration
```bash
terraform apply -var-file="terraform.dev.tfvars" -var="bucket_name=jenkins-tfstate-platform"
```

### 7. Test Vault Integration
Set the Vault inputs in your shell and keep the repository free of Vault tfvars files:
```bash
export TF_VAR_enable_vault_integration=true
export TF_VAR_vault_address="http://127.0.0.1:8200"
export TF_VAR_vault_token="root"
export TF_VAR_vault_kv_mount="secret"
export TF_VAR_vault_secret_path="jenkins/platform/test"
export TF_VAR_vault_secret_key="value"
terraform plan -var-file="terraform.dev.tfvars"
```

If you need a local dev server, start one in another terminal:
```bash
vault server -dev -dev-root-token-id=root
```

Then create the test secret:
```bash
vault kv put secret/jenkins/platform/test value="hello-from-vault"
```

If the secret exists in the local Vault server, Terraform will expose it through the sensitive output `vault_test_secret_value`.

## Common Tasks

### Creating a New Environment
See [Creating Environments](./creating-environments.md)

### Scaling Your Jenkins Instance
See [Scaling Guide](./runbooks/scaling-jenkins.md)

### Disaster Recovery
See [Disaster Recovery](./runbooks/disaster-recovery.md)

## Support

- 📖 [Backstage Documentation](https://backstage.yourorganization.com)
- 💬 Slack: #platform-engineering
- 📧 Email: platform-team@yourorganization.com

## Next Steps

1. Review the [Architecture Documentation](./architecture.md)
2. Check out [Best Practices](./best-practices.md)
3. Explore available [Templates](../templates/)
