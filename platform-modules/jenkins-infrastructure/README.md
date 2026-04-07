# Jenkins Infrastructure Module for Platform Engineers

This is a high-level platform module that simplifies Jenkins deployment on AWS by abstracting the underlying Terraform modules.

## What This Module Does

- ✅ Deploys complete Jenkins infrastructure
- ✅ Configures networking (VPC, subnets, security groups)
- ✅ Sets up load balancers
- ✅ Manages SSL/TLS certificates
- ✅ Configures DNS
- ✅ Sends alerts on EC2 failures
- ✅ Enables CloudWatch monitoring

## Key Differences from Raw Terraform

| Aspect | Raw Terraform | Platform Module |
|--------|---------------|-----------------|
| **Learning Curve** | Steep | Gentle |
| **Variables** | ~20+ | ~10 (simplified) |
| **Outputs** | Technical | User-friendly |
| **Defaults** | Minimal | Sensible defaults |
| **Best Practices** | Manual | Built-in |

## Usage Example

```hcl
module "jenkins_platform" {
  source = "../platform-modules/jenkins-infrastructure"

  # Basic configuration
  environment      = "production"
  project_name     = "my-jenkins"
  
  # Sizing
  instance_size    = "large"  # micro, small, medium, large, xlarge
  
  # Network
  vpc_cidr         = "10.0.0.0/16"
  enable_nat_gateway = true
  
  # Optional customization
  tags = {
    Owner       = "platform-team"
    CostCenter  = "engineering"
  }
}

# Access outputs
output "jenkins_url" {
  value = module.jenkins_platform.jenkins_access_url
}
```

## Inputs

### Required
- `environment` - Environment name (dev, qa, prod)
- `project_name` - Project identifier

### Optional
- `instance_size` - Instance size (default: medium)
- `vpc_cidr` - VPC CIDR block (default: 10.0.0.0/16)
- `enable_nat_gateway` - Enable NAT for private subnets (default: true)
- `tags` - Resource tags (default: {})

## Outputs

- `jenkins_url` - URL to access Jenkins
- `jenkins_instance_id` - EC2 instance ID
- `vpc_id` - VPC identifier
- `security_groups` - Security group information
- `monitoring_dashboard` - CloudWatch dashboard URL

## See Also

- [Platform Engineer Documentation](../../platform-standards/PLATFORM-ENGINEERS.md)
- [Examples](../examples/)
- [Best Practices](../../docs/best-practices.md)
