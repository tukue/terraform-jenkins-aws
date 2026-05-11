# Backstage EC2 Module

This module creates an EC2 instance for running Backstage with Docker.

## Usage

```hcl
module "backstage_ec2" {
  source = "./modules/backstage-ec2"

  environment      = "production"
  instance_type    = "t3.large"
  root_volume_size = 100
  
  subnet_id             = module.vpc.public_subnet_ids[0]
  security_group_ids    = [aws_security_group.backstage.id]
  iam_instance_profile  = aws_iam_instance_profile.backstage.name
  
  # Database connection
  db_host     = module.backstage_postgres.db_address
  db_port     = module.backstage_postgres.db_port
  db_name     = "backstage"
  db_user     = "backstage_admin"
  db_password_secret_arn = module.backstage_postgres.master_user_secret_arn

  # GitHub integration
  github_client_id     = var.github_client_id
  github_client_secret = var.github_client_secret
  github_token         = var.github_token
  
  tags = {
    Environment = "production"
    Service     = "Backstage"
  }
}
```

## Outputs

- `instance_id` - EC2 instance ID
- `instance_ip` - Public IP address
- `instance_hostname` - Instance hostname

## Prerequisites

- VPC with public subnet
- Security group for Backstage
- IAM instance profile with ECR, CloudWatch, and Secrets Manager permissions
- RDS PostgreSQL database
- GitHub OAuth2 credentials
