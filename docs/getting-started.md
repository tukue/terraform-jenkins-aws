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

If the backend resources do not exist yet, bootstrap them first:
```bash
bash ./terraform-bootstrap.sh dev terraform-jenkins-aws-state-store-bucket
```

### 5. Plan the Infrastructure
```bash
terraform plan -var-file="terraform.dev.tfvars"
```

### 6. Apply Configuration
```bash
terraform apply -var-file="terraform.dev.tfvars" -var="bucket_name=jenkins-tfstate-platform"
```

### 7. Run the Automated Apply
```bash
bash ./terraform-apply.sh dev terraform-jenkins-aws-state-store-bucket
```

This wrapper runs `terraform init`, `terraform plan`, and `terraform apply` with the correct environment tfvars file so Terraform does not pause for `cidr_private_subnet` or any of the other required inputs.

Use the bootstrap wrapper only once per environment, before the remote backend exists. After that, use the normal apply wrapper.

### 8. Test Vault Integration
For a local Vault dev server, use the basic Vault tfvars file and run the plan with both tfvars files:
```bash
terraform plan -var-file="terraform.dev.tfvars" -var-file="terraform.vault.tfvars"
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

The local overlay keeps the Vault settings separate from the environment tfvars so the minimum local test is just:
- `terraform.dev.tfvars`
- `terraform.vault.tfvars`
- a Vault dev server listening on `http://127.0.0.1:8200`

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
