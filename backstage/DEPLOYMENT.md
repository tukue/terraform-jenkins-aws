# Backstage Deployment Guide

This guide uses existing resources and documentation to deploy Backstage infrastructure.

## Quick Reference

| Component | Location |
|-----------|----------|
| **Docker Setup** | [BACKSTAGE-QUICKSTART.md](../BACKSTAGE-QUICKSTART.md) |
| **GitHub Integration** | [.backstage/GITHUB-INTEGRATION-SETUP.md](.backstage/GITHUB-INTEGRATION-SETUP.md) |
| **Catalog Configuration** | [catalog-info.yaml](../catalog-info.yaml) |
| **System Definitions** | [.backstage/system-and-components.yaml](.backstage/system-and-components.yaml) |
| **Teams & Users** | [.backstage/groups-and-users.yaml](.backstage/groups-and-users.yaml) |
| **App Configuration** | [.backstage/app-config.yaml.example](.backstage/app-config.yaml.example) |
| **Terraform Modules** | [backstage/modules/](./modules/) |

## Phase 1: Preparation (30 minutes)

### 1.1 Set Up GitHub OAuth2
**Reference**: [GITHUB-INTEGRATION-SETUP.md](.backstage/GITHUB-INTEGRATION-SETUP.md)

Follow steps 1-5 to:
- Create GitHub OAuth2 application
- Create GitHub personal access token
- Get Client ID, Client Secret, and Token

### 1.2 Prepare AWS Credentials
```bash
# Configure AWS CLI with your account
aws configure
```

### 1.3 Create SSH Key Pair
```bash
# Create key pair for EC2 access
aws ec2 create-key-pair --key-name backstage-key --query 'KeyMaterial' --output text > backstage-key.pem
chmod 600 backstage-key.pem
```

## Phase 2: Terraform Configuration (15 minutes)

### 2.1 Prepare Terraform Variables
```bash
cd backstage/

# Copy example config
cp backstage.tfvars.example backstage.tfvars

# Edit with your values
vim backstage.tfvars
```

Update these values:
```hcl
environment              = "dev"  # or "qa", "prod"
github_client_id         = "your-client-id"
github_client_secret     = "your-client-secret"
github_token             = "your-token"
db_password              = "YourSecurePassword123!"
key_name                 = "backstage-key"
```

### 2.2 Initialize Terraform
```bash
terraform init
```

### 2.3 Review Deployment Plan
```bash
terraform plan -var-file="backstage.tfvars"
```

Review the output to verify:
- VPC and subnets
- RDS PostgreSQL instance
- EC2 instance
- Security groups and IAM roles

## Phase 3: Deploy Infrastructure (5-10 minutes)

### 3.1 Deploy Backstage
```bash
terraform apply -var-file="backstage.tfvars"
```

This creates:
- ✅ VPC with public/private subnets
- ✅ PostgreSQL RDS database
- ✅ Backstage EC2 instance
- ✅ Security groups and IAM roles
- ✅ Elastic IP for stable access
- ✅ CloudWatch monitoring

### 3.2 Capture Output
```bash
# Save connection information
terraform output -json > backstage-outputs.json

# View key outputs
terraform output backstage_url
terraform output backstage_elastic_ip
terraform output backstage_ssh_command
```

## Phase 4: Verify Deployment (10 minutes)

### 4.1 Connect to Backstage
```bash
# Get the URL from output
BACKSTAGE_URL=$(terraform output -raw backstage_url)
open $BACKSTAGE_URL  # macOS
# or xdg-open $BACKSTAGE_URL  # Linux
# or start $BACKSTAGE_URL  # Windows
```

### 4.2 SSH into Instance
```bash
# Get SSH command
terraform output -raw backstage_ssh_command

# Example:
ssh -i backstage-key.pem ec2-user@1.2.3.4
```

### 4.3 Check Docker Status
```bash
ssh -i backstage-key.pem ec2-user@$(terraform output -raw backstage_public_ip)

# Check Docker Compose status
docker-compose -f /opt/backstage/docker-compose.yml ps

# View logs
docker-compose -f /opt/backstage/docker-compose.yml logs -f backstage
```

## Phase 5: Configure Catalog (20 minutes)

### 5.1 View System Definitions
The following are already configured in:
- **System**: [.backstage/system-and-components.yaml](.backstage/system-and-components.yaml)
- **Teams**: [.backstage/groups-and-users.yaml](.backstage/groups-and-users.yaml)
- **Catalog**: [catalog-info.yaml](../catalog-info.yaml)

### 5.2 Access Backstage Portal
1. Open Backstage at: `http://<elastic-ip>:3000`
2. Click "Sign in" and select GitHub
3. Navigate to **Catalog**
4. You should see:
   - **Systems**: jenkins-platform
   - **Components**: All Terraform modules and Ansible configuration
   - **Groups**: Platform team, DevOps team, Security team

### 5.3 Verify Catalog Sync
```bash
# SSH into instance
ssh -i backstage-key.pem ec2-user@$(terraform output -raw backstage_public_ip)

# Check Backstage logs
docker logs backstage | grep -i catalog

# Expected output:
# [catalog] Refresh task completed
# [catalog] Added 15 entities
```

## Phase 6: Configure GitHub Integration (10 minutes)

### 6.1 Set Environment Variables
Already configured in EC2 user_data from:
- `GITHUB_CLIENT_ID`
- `GITHUB_CLIENT_SECRET`
- `GITHUB_TOKEN`

### 6.2 Verify GitHub Sync
```bash
# SSH into instance
ssh -i backstage-key.pem ec2-user@$(terraform output -raw backstage_public_ip)

# Check if GitHub integration is working
curl http://localhost:3000/api/catalog/entities?kind=Component | jq '.items | length'

# Should return a number > 0
```

## Troubleshooting

### Backstage Not Starting
```bash
# SSH into instance
ssh -i backstage-key.pem ec2-user@$(terraform output -raw backstage_public_ip)

# Check service status
systemctl status docker

# Restart Docker Compose
cd /opt/backstage
docker-compose down
docker-compose up -d

# View detailed logs
docker-compose logs -f
```

### Database Connection Issues
```bash
# Check RDS endpoint
POSTGRES_ENDPOINT=$(terraform output -raw rds_endpoint)

# Verify network connectivity
ssh -i backstage-key.pem ec2-user@$(terraform output -raw backstage_public_ip)
nc -zv $POSTGRES_ENDPOINT

# Check security group
aws ec2 describe-security-groups --group-ids sg-xxxxx --query 'SecurityGroups[0].IpPermissions'
```

### Catalog Not Syncing
1. Verify `GITHUB_TOKEN` is valid with correct scopes
   - See: [GITHUB-INTEGRATION-SETUP.md](.backstage/GITHUB-INTEGRATION-SETUP.md)
2. Check that catalog files exist in repository:
   ```bash
   curl https://raw.githubusercontent.com/tukue/terraform-jenkins-aws/main/catalog-info.yaml
   ```
3. Verify entity references (owner, system) exist
4. Check Docker logs: See above

## Cleanup

### Destroy All Resources
```bash
# From backstage directory
terraform destroy -var-file="backstage.tfvars"

# Remove local files (optional)
rm -rf backstage-outputs.json backstage.tfvars
```

## Next Steps

1. ✅ **Deployed**: Backstage is running with GitHub integration
2. 📚 **Documentation**: Review TechDocs in Backstage
3. 🔧 **Customize**: Add your own components and templates
4. 🚀 **Enable**: Turn on additional Backstage plugins (Kubernetes, Prometheus, etc.)

## Reusing Existing Resources

This deployment leverages:
- [Backstage Quick Start](../BACKSTAGE-QUICKSTART.md) - App setup guide
- [GitHub Integration](../.backstage/GITHUB-INTEGRATION-SETUP.md) - OAuth2 setup
- [System Definitions](../.backstage/system-and-components.yaml) - Catalog structure
- [App Configuration](../.backstage/app-config.yaml.example) - Configuration reference
- [Terraform Modules](./modules/) - Infrastructure as Code

**Every component is reused and referenced from existing documentation.**

## Support

For issues:
- Check [GITHUB-INTEGRATION-SETUP.md](.backstage/GITHUB-INTEGRATION-SETUP.md) troubleshooting
- Review [BACKSTAGE-QUICKSTART.md](../BACKSTAGE-QUICKSTART.md) for Docker issues  
- Check Terraform outputs with: `terraform output`
- Review EC2 instance logs: See troubleshooting section above

---

**Key Reference Files**:
- 📖 [BACKSTAGE-QUICKSTART.md](../BACKSTAGE-QUICKSTART.md) - 5-min setup
- 🔐 [GITHUB-INTEGRATION-SETUP.md](.backstage/GITHUB-INTEGRATION-SETUP.md) - GitHub OAuth2
- 📋 [System & Components](.backstage/system-and-components.yaml) - Catalog structure
- 🛠️ [App Config](.backstage/app-config.yaml.example) - Configuration template
