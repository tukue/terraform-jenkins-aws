# Best Practices for terraform-jenkins-aws Platform

## Terraform Best Practices

### Module Organization
```
modules/
├── networking/
│   ├── main.tf          # Module implementation
│   ├── variables.tf     # Input variables
│   ├── outputs.tf       # Output values
│   └── README.md        # Module documentation
├── security-groups/
└── compute/
```

**Principle**: Each module should be independently deployable and testable.

### Variable Naming
```hcl
# Good
variable "instance_type" { }
variable "enable_monitoring" { }
variable "tag_owner" { }

# Bad
variable "it" { }
variable "mon" { }
variable "owner_tag" { }
```

### State Management
```hcl
# Always use remote backend for team environments
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

### Error Handling
```hcl
# Validate critical variables
variable "database_password" {
  type        = string
  sensitive   = true
  description = "Database password (minimum 16 characters)"
  
  validation {
    condition     = length(var.database_password) >= 16
    error_message = "Database password must be at least 16 characters."
  }
}
```

## AWS Best Practices

### Security
```hcl
# Enable encryption for all resources
resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.example.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Use security groups for network control
resource "aws_security_group" "app" {
  name = "app-sg"

  # Allow only necessary ports
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  # Restrict outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### Cost Optimization
```hcl
# Use appropriate instance types
# Right-size based on actual workload

# Use Auto Scaling for variable loads
resource "aws_autoscaling_group" "example" {
  name                = "example-asg"
  vpc_zone_identifier = aws_subnet.private[*].id
  min_size            = 1
  max_size            = 5
  desired_capacity    = 2

  # Mix of spot and on-demand instances
  mixed_instances_policy {
    instances_distribution {
      on_demand_percentage_above_base_capacity = 20
    }
  }
}
```

### High Availability
```hcl
# Multi-AZ deployments
resource "aws_instance" "app" {
  count             = 2
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "app-${count.index}"
  }
}

# Load balancing
resource "aws_lb" "main" {
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id
  
  enable_deletion_protection = true
  enable_http2              = true
}
```

### Monitoring & Logging
```hcl
# CloudWatch metrics
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

# Application logging
resource "aws_cloudwatch_log_group" "app" {
  name              = "/aws/ec2/jenkins"
  retention_in_days = 30
}
```

## Jenkins Best Practices

### Configuration
- Use Docker for Jenkins agents
- Configure agent pools by workload type
- Set workspace cleanup policies
- Configure build timeout: 2 hours max

### Security
- Update Jenkins regularly
- Enable CSRF protection
- Use OAuth2 for authentication
- Rotate SSH keys quarterly
- Encrypt Jenkins credentials

### Performance
- Configure build executors: (CPU cores - 1)
- Use distributed builds with agents
- Archive only necessary artifacts
- Configure workspace cleanup

### Monitoring
```groovy
// Monitor build metrics
pipeline {
  options {
    timestamps()
    timeout(time: 2, unit: 'HOURS')
    buildDiscarder(logRotator(numToKeepStr: '30'))
  }
  
  post {
    always {
      junit 'test-results/**/*.xml'
      archiveArtifacts 'build/outputs/**'
    }
    failure {
      emailext(to: 'team@example.com', subject: 'Build Failed')
    }
  }
}
```

## Infrastructure as Code Best Practices

### DRY Principle
- Use modules to avoid repetition
- Use variables for configuration
- Use locals for computed values
- Use data sources for existing resources

### Testing
```bash
# Validate syntax
terraform validate

# Format check
terraform fmt -check -recursive .

# Security scanning
checkov -d .
tflint .

# Compliance check
terraform plan -json | jq '..'

# Cost estimation
terraform plan -json | jq '.resource_changes[] | select(.change.actions[] == "create")'
```

### Documentation
```hcl
# Document every variable
variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 instance type (see https://aws.amazon.com/ec2/instance-types)"
}

# Document every output
output "instance_ip" {
  value       = aws_instance.main.public_ip
  description = "Public IP of the Jenkins instance"
}
```

## Git Workflow Best Practices

### Branch Strategy
- `main`: Production-ready code
- `develop`: Development branch
- `feature/*`: Feature branches
- `hotfix/*`: Emergency fixes

### Commit Message Format
```
feat(module): add new feature

This is a more detailed explanation of the change.

Closes #123
```

### Pull Request Checklist
- [ ] Changes tested locally
- [ ] Documentation updated
- [ ] No breaking changes
- [ ] Code follows standards
- [ ] Security reviewed
- [ ] Performance impact assessed

## Monitoring & Alerting

### Key Metrics
- Instance health: CPU, memory, disk
- Application health: Response time, error rate
- Infrastructure health: Connection count, packet loss
- Cost metrics: Daily spend, forecast

### Alert Thresholds
| Metric | Warning | Critical | Action |
|--------|---------|----------|--------|
| CPU | >70% | >85% | Scale up |
| Memory | >80% | >95% | Investigate |
| Disk | >80% | >95% | Clean up |
| Error Rate | >1% | >5% | Page on-call |

## Incident Response

### Response Plan
1. **Detect**: Monitor and alert
2. **Respond**: Engage on-call engineer
3. **Mitigate**: Stop the bleeding
4. **Resolve**: Fix root cause
5. **Learn**: Post-mortem and improve

### Escalation
- Critical: Page on-call immediately
- High: Notify team within 15 min
- Medium: Notify team within 1 hour
- Low: Create ticket for later

## Related Documentation
- [Platform Standards](./STANDARDS.md)
- [Contributing Guidelines](../CONTRIBUTING.md)
- [Architecture Guide](../docs/architecture.md)
