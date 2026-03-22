# Platform Examples

This directory contains example configurations for deploying platform infrastructure using the shared modules.

## Quick Start

1. **Copy an example file:**
   ```bash
   cp qa-environment.tfvars my-jenkins.tfvars
   ```

2. **Edit the variables:**
   ```bash
   # Customize for your needs
   vim my-jenkins.tfvars
   ```

3. **Deploy:**
   ```bash
   terraform init
   terraform plan -var-file=my-jenkins.tfvars
   terraform apply -var-file=my-jenkins.tfvars
   ```

## Example Files

### dev-environment.tfvars
- **Purpose**: Minimal development setup
- **Instance**: t3.small (cost-effective)
- **Network**: Single AZ, no NAT Gateway
- **Monitoring**: Basic (inherited from module defaults)
- **Use Case**: Testing changes, development work

### qa-environment.tfvars
- **Purpose**: QA/Staging environment
- **Instance**: t3.medium (balanced performance/cost)
- **Network**: Multi-AZ with NAT Gateway
- **Monitoring**: Enabled
- **Use Case**: Pre-production testing, integration testing

### prod-environment.tfvars
- **Purpose**: Production deployment
- **Instance**: t3.large (high performance)
- **Network**: Multi-AZ with full HA
- **Monitoring**: Full CloudWatch monitoring
- **Use Case**: Production Jenkins servers

### customer-ecs-runtime/
- **Purpose**: Customer-specific ECS runtime example
- **Runtime**: ECS Fargate
- **Network**: Customer VPC with public ALB and private tasks
- **Monitoring**: CloudWatch logs and ECS container insights
- **Use Case**: Multi-tenant SaaS onboarding and customer-dedicated runtimes

## Customization Guide

### Required: SSH Public Key
```hcl
public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC..."  # Your SSH public key
```
**Important**: Replace with your actual SSH public key content. This is required for EC2 instance access.

### Environment Names
```hcl
environment = "dev"  # dev, qa, prod
```

### Project Naming
```hcl
project_name = "my-jenkins"  # Used in resource names
```

### Instance Sizing
```hcl
instance_size = "medium"  # micro, small, medium, large, xlarge
```

### Network Configuration
```hcl
vpc_cidr = "10.0.0.0/16"  # Your VPC CIDR
availability_zones = ["us-east-1a", "us-east-1b"]  # Specific AZs
enable_nat_gateway = true  # For private subnet internet access
```

### Tags
```hcl
tags = {
  Owner       = "platform-team"
  CostCenter  = "engineering"
  Environment = "production"
}
```

## See Also

- [Platform Module Documentation](../platform-modules/jenkins-infrastructure/README.md)
- [Customer ECS Runtime Module](../platform-modules/customer-ecs-runtime/README.md)
- [Best Practices](../../docs/best-practices.md)
- [Deployment Guide](../../DEPLOYMENT-GUIDE.md)
