# Main Terraform Configuration for Backstage Deployment

This directory contains the root Terraform configuration for deploying Backstage infrastructure.

## Usage

```bash
# Initialize Terraform
terraform init

# Review what will be created
terraform plan -var-file="backstage.tfvars"

# Deploy Backstage
terraform apply -var-file="backstage.tfvars"
```

## Local Docker Containerization

Use Docker Compose from this directory to run Backstage and PostgreSQL locally:

```bash
# Create local environment values
cp .env.example .env

# Start stack
docker compose up -d

# Check containers
docker compose ps
```

Backstage will be available at `http://localhost:3000`.

Grafana will be available at `http://localhost:3001` and Prometheus at `http://localhost:9090`.

To stop:

```bash
docker compose down
```

## Files

- **main.tf** - Root module orchestration
- **variables.tf** - Input variables
- **outputs.tf** - Output values
- **vpc.tf** - VPC and networking
- **security.tf** - Security groups and IAM roles
- **backstage.tf** - Backstage EC2 and RDS deployment

## Modules Used

- `./modules/backstage-postgres/` - PostgreSQL RDS instance
- `./modules/backstage-ec2/` - Backstage EC2 instance

## Prerequisites

1. AWS account with credentials configured
2. GitHub OAuth2 credentials (see [GITHUB-INTEGRATION-SETUP.md](../.backstage/GITHUB-INTEGRATION-SETUP.md))
3. VPC and networking resources

## Configuration

Create `backstage.tfvars`:

```hcl
environment       = "production"
aws_region        = "your-aws-region"

# GitHub OAuth2
github_client_id     = "your-client-id"
github_client_secret = "your-client-secret"
github_token         = "your-github-token"

# Database
db_password = "your-secure-password"

# EC2
instance_type = "t3.large"
key_name      = "your-ssh-key"
```

## Output

After deployment, Terraform will output:
- Backstage Portal URL
- RDS database endpoint
- EC2 instance details

## Related Documentation

- [Backstage Quick Start](../../BACKSTAGE-QUICKSTART.md)
- [GitHub Integration Setup](../../.backstage/GITHUB-INTEGRATION-SETUP.md)
- [System and Components](../../.backstage/system-and-components.yaml)
- [Catalog Configuration](../../catalog-info.yaml)
