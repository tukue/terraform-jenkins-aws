# Platform Deployment Guide

## Deployment Strategy

This guide covers deploying the terraform-jenkins-aws platform to production.

## Prerequisites

Before deploying, ensure you have:

1. **AWS Account Setup**
   - AWS account with appropriate IAM permissions
   - AWS CLI configured with credentials
   - AWS region selected (e.g., us-east-1)

2. **Local Tools**
   - Terraform >= 1.0
   - Git
   - SSH key pair
   - Ansible (for configuration)

3. **GitHub**
   - Repository forked/cloned
   - GitHub PAT for automated deployments
   - Branch protection rules configured

4. **Team Readiness**
   - Team trained on platform
   - Runbooks reviewed
   - On-call rotation active
   - Communication channels established

## Deployment Phases

### Phase 1: Development Environment (Week 1)

Deploy to dev environment for initial testing.

```bash
# 1. Clone repository
git clone https://github.com/tukue/terraform-jenkins-aws.git
cd terraform-jenkins-aws

# 2. Create workspace
terraform workspace new dev
terraform workspace select dev

# 3. Initialize with dev backend
terraform init -backend-config="backend-config-dev.hcl"

# 4. Plan deployment
terraform plan -var-file="terraform.dev.tfvars" -out=dev.plan

# 5. Review plan carefully
# Check for any unexpected changes

# 6. Apply changes
terraform apply dev.plan

# 7. Configure Jenkins
cd ansible/
ansible-playbook -i inventory/aws_ec2.yml playbook/jenkins-setup.yml

# 8. Verify deployment
# Access Jenkins at: http://<jenkins-dev-ip>:8080
```

**Success Criteria**:
- Jenkins accessible and functional
- All EC2 instances healthy
- Load balancer responding
- No security group issues
- Backup job scheduled

### Phase 2: QA Environment (Week 2)

Deploy to QA for more extensive testing.

```bash
# 1. Create QA workspace
terraform workspace new qa
terraform workspace select qa

# 2. Initialize with QA backend
terraform init -backend-config="backend-config-qa.hcl"

# 3. Deploy with QA variables
terraform plan -var-file="terraform.qa.tfvars" -out=qa.plan
terraform apply qa.plan

# 4. Configure QA Jenkins
ansible-playbook -i inventory/aws_ec2.yml playbook/jenkins-setup.yml \
  -e "environment=qa"

# 5. Load testing
# Use JMeter or similar to test load capacity
# Target: 50 concurrent builds

# 6. Security scanning
checkov -d . --framework terraform
tflint .

# 7. Document findings
# Update runbooks based on QA learnings
```

**Success Criteria**:
- Passes load testing
- No security vulnerabilities
- Documentation complete
- Team trained on QA environment
- Backup and recovery tested

### Phase 3: Production Deployment (Week 3-4)

Deploy to production with high confidence.

```bash
# 1. Pre-deployment checklist
# [ ] All QA tests passed
# [ ] Security approval obtained
# [ ] Team trained
# [ ] Runbooks reviewed
# [ ] Monitoring configured
# [ ] Alerts tested

# 2. Create production workspace
terraform workspace new production
terraform workspace select production

# 3. Production initialization
terraform init -backend-config="backend-config-prod.hcl"

# 4. Plan production deployment
terraform plan -var-file="terraform.prod.tfvars" -out=prod.plan

# 5. Security review
# Have team review the plan
# Check for any risky changes
# Verify all security controls in place

# 6. Apply production changes
# This should be done during maintenance window
terraform apply prod.plan

# 7. Configure production Jenkins
ansible-playbook -i inventory/aws_ec2.yml playbook/jenkins-setup.yml \
  -e "environment=production" \
  -e "enable_backups=true"

# 8. Verify production deployment
./scripts/verify-deployment.sh

# 9. Enable monitoring and alerting
aws cloudwatch put-metric-alarm \
  --alarm-name jenkins-high-cpu \
  --alarm-actions arn:aws:sns:us-east-1:123456789:alerts

# 10. Final validation
# Test backup/restore
# Test failover procedures
# Verify DNS resolution
# Test SSL certificates
```

**Success Criteria**:
- All systems operational
- Monitoring showing normal metrics
- Alerts configured and tested
- SLA objectives met
- Team confident in operations
- Documentation complete

## Deployment Configuration Files

Create environment-specific configuration files:

### terraform.dev.tfvars
```hcl
environment       = "dev"
instance_type     = "t3.micro"
instance_count    = 1
backup_retention  = 7
enable_monitoring = true
min_size          = 1
max_size          = 2
```

### terraform.qa.tfvars
```hcl
environment       = "qa"
instance_type     = "t3.small"
instance_count    = 2
backup_retention  = 14
enable_monitoring = true
min_size          = 2
max_size          = 4
```

### terraform.prod.tfvars
```hcl
environment       = "production"
instance_type     = "t3.medium"
instance_count    = 3
backup_retention  = 30
enable_monitoring = true
min_size          = 2
max_size          = 5
```

## Automated Deployment (CI/CD)

Use the checked-in GitHub Actions workflow at [`.github/workflows/jenkins-platform-delivery.yml`](./.github/workflows/jenkins-platform-delivery.yml) to:

- validate Terraform formatting and configuration
- plan `dev`, `qa`, and `prod` deployments
- apply the selected environment through a manual workflow dispatch
- keep environment-specific state in `backend-config-dev.hcl`, `backend-config-qa.hcl`, and `backend-config-prod.hcl`

The workflow expects an `AWS_ROLE_ARN` secret in GitHub and uses GitHub environments to gate applies.
The S3 backend bucket and DynamoDB lock table must already be bootstrapped before the first environment run.

## Rollback Procedures

If deployment fails:

### 1. Immediate Rollback
```bash
# Revert to previous state
git revert HEAD
terraform plan
terraform apply

# Or use Terraform state backup
terraform state rm aws_instance.jenkins
# Restore from backup
```

### 2. Partial Rollback
```bash
# If only some resources failed
terraform destroy -target=aws_instance.jenkins
terraform apply -target=aws_instance.jenkins
```

### 3. Full Environment Restore
```bash
# If critical failure occurred
# 1. Verify backup still valid
aws ec2 describe-snapshots --owner-ids self

# 2. Restore from backup
./scripts/restore-from-backup.sh production

# 3. Verify restoration
./scripts/verify-deployment.sh
```

## Post-Deployment

After successful deployment:

1. **Monitor**: Watch metrics for 24-48 hours
2. **Document**: Update runbooks with learnings
3. **Communicate**: Send success notification to team
4. **Review**: Conduct post-deployment review
5. **Plan**: Next improvements and enhancements

## Support & Escalation

**For deployment issues**:
- Slack: #platform-engineering
- Email: platform-team@organization.com
- PagerDuty: Critical issues

## Related Documentation
- [Implementation Backlog](../IMPLEMENTATION-BACKLOG.md)
- [Architecture Guide](../docs/architecture.md)
- [Operations Runbooks](../docs/runbooks/)
