# Scaling Jenkins - Operational Runbook

## Overview

This runbook provides step-by-step instructions for scaling the Jenkins infrastructure to handle increased workloads.

## Indicators You Need to Scale

Monitor these metrics to determine if scaling is needed:

- **CPU Usage**: Consistently >80% over 10 minutes
- **Memory Usage**: Consistently >85%
- **Queue Depth**: More than 10 jobs waiting in queue
- **Response Time**: API response time >2 seconds
- **Build Failure Rate**: Increased timeouts or failures

## Scaling Options

### 1. Vertical Scaling (Instance Type Upgrade)

Increase instance compute resources.

#### Prerequisites
- Maintenance window scheduled
- Backup of current state created
- Team notified

#### Steps

```bash
# 1. Stop Jenkins gracefully
# In Jenkins UI: Manage Jenkins → Prepare for Shutdown
# Wait for running jobs to complete (~15 min)

# 2. Update Terraform variables
# Edit terraform.tfvars
# Change instance_type = "t3.medium" → "t3.large"

# 3. Plan and review changes
terraform plan -var-file="terraform.tfvars"

# 4. Apply changes
terraform apply -var-file="terraform.tfvars"

# 5. Verify EC2 instance state
aws ec2 describe-instances --instance-ids i-xxxxx

# 6. SSH into instance and verify resources
ssh -i your-key.pem ec2-user@jenkins-public-ip
free -m        # Check memory
nproc          # Check CPU cores
df -h          # Check disk space

# 7. Start Jenkins (should auto-start)
# Verify Jenkins is responding
curl http://localhost:8080

# 8. Post-scaling validation
# In Jenkins UI: Check system performance metrics
```

**Downtime**: 10-20 minutes  
**Rollback**: Decrease instance_type and reapply

### 2. Horizontal Scaling (Multiple Jenkins Agents)

Add more Jenkins agent nodes to distribute workload.

#### Prerequisites
- Jenkins controller remains unchanged
- Agents can be in separate EC2 instances
- Network connectivity between controller and agents

#### Steps

```bash
# 1. Create new Jenkins agent Terraform module
cd jenkins-agents/
cat > main.tf << 'EOF'
resource "aws_instance" "jenkins_agent" {
  count                = var.agent_count
  ami                  = var.ami_id
  instance_type        = var.instance_type
  subnet_id            = var.subnet_id
  iam_instance_profile = aws_iam_instance_profile.jenkins_agent.name
  
  tags = {
    Name = "jenkins-agent-${count.index + 1}"
  }
}
EOF

# 2. Configure for Jenkins agent
terraform init
terraform plan
terraform apply

# 3. In Jenkins UI:
# - Manage Jenkins → Manage Nodes and Clouds
# - New Node
# - Configure agent with SSH connection
# - Set executors: 2-4 per agent
# - Set labels for workload distribution

# 4. Test connectivity
# In Jenkins: Test Connection (in agent config)

# 5. Monitor agent performance
# Manage Jenkins → Monitoring → Metrics
```

**Downtime**: 0 minutes  
**Rollback**: Remove agents and reduce agent_count

### 3. Load Balancing Optimization

Optimize current load balancer configuration.

#### Steps

```bash
# 1. Review ALB configuration
aws elbv2 describe-load-balancers --names jenkins-alb

# 2. Check target group health
aws elbv2 describe-target-health --target-group-arn arn:aws:...

# 3. Adjust connection draining timeout
# Current: 300 seconds (good for long-running builds)
# Increase if builds take >5 minutes

# 4. Enable connection multiplexing
# In ALB listener settings
# HTTP/2 enabled (already default)

# 5. Monitor latency metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name TargetResponseTime \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T01:00:00Z \
  --period 300 \
  --statistics Average,Maximum
```

### 4. Storage Scaling

Increase disk space for Jenkins workspace and build artifacts.

#### Prerequisites
- Sufficient EBS volume capacity available
- Backup taken
- Scheduled during low-traffic period

#### Steps

```bash
# 1. Check current usage
df -h /var/lib/jenkins

# 2. Create new EBS volume
aws ec2 create-volume \
  --size 100 \
  --volume-type gp3 \
  --availability-zone us-east-1a

# 3. Attach to instance
aws ec2 attach-volume \
  --volume-id vol-xxxxx \
  --instance-id i-xxxxx \
  --device /dev/sdf

# 4. Stop Jenkins
systemctl stop jenkins

# 5. Mount new volume
lsblk  # Find new device
sudo mkfs.ext4 /dev/nvme1n1p1
sudo mount /dev/nvme1n1p1 /mnt/jenkins-storage

# 6. Move Jenkins data
sudo rsync -av /var/lib/jenkins/ /mnt/jenkins-storage/
sudo systemctl start jenkins

# 7. Update fstab for persistence
sudo vim /etc/fstab
# Add: /dev/nvme1n1p1 /mnt/jenkins-storage ext4 defaults,nofail 0 2

# 8. Verify
df -h /mnt/jenkins-storage
systemctl status jenkins
```

## Monitoring After Scaling

After scaling, monitor these metrics:

```bash
# CPU and Memory
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T01:00:00Z \
  --period 300 \
  --statistics Average

# Jenkins queue depth
# In Jenkins API: curl http://localhost:8080/api/json

# Build success rate
# In Jenkins UI: Navigate to builds and check status
```

## Rollback Procedures

### If Scaling Causes Issues

```bash
# 1. Revert Terraform changes
git revert last-commit-hash
terraform plan
terraform apply

# 2. Restore from backup (if needed)
aws ec2 create-image --instance-id i-xxxxx --name jenkins-backup

# 3. Notify team
# Post message in #incidents channel

# 4. Investigate root cause
# Check CloudWatch logs
# Review error messages
# Document findings
```

## Performance Tuning After Scaling

```bash
# 1. Adjust Jenkins JVM heap
sudo vim /etc/default/jenkins
# JAVA_ARGS="-Xms4g -Xmx4g"  # Adjust based on available memory

# 2. Increase thread pool size
# In Jenkins: Manage Jenkins → Configure System
# Set executors based on: (CPU cores - 1)

# 3. Optimize plugins
# Disable unused plugins
# Update plugins to latest versions

# 4. Configure distributed builds
# Use Jenkins Distributed Build feature
# Configure build timeout appropriately

# 5. Cost optimization
# Consider Spot Instances for agents
# Use Reserved Instances for controller
```

## Support & Escalation

**For Issues during Scaling**:
1. Slack: #platform-engineering
2. PagerDuty: Escalate if critical
3. AWS Support: For AWS-related issues

## Related Documentation

- [Architecture Overview](../architecture.md)
- [Disaster Recovery](./disaster-recovery.md)
- [Monitoring Guide](./monitoring.md)
