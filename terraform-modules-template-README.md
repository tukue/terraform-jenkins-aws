# README for Platform Templates

This directory contains reusable Terraform templates for infrastructure components.

## Using Templates

### 1. VPC Template
Create a new VPC with public and private subnets.

```hcl
module "vpc" {
  source = "./templates/vpc"
  
  environment = "production"
  cidr_block  = "10.0.0.0/16"
  
  public_subnet_count  = 2
  private_subnet_count = 2
  
  tags = {
    Environment = "production"
  }
}
```

### 2. Security Group Template
Create security groups with common rules.

```hcl
module "web_sg" {
  source = "./templates/security-group"
  
  name        = "web-security-group"
  description = "Security group for web servers"
  vpc_id      = module.vpc.id
  
  rules = [{
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }]
}
```

### 3. EC2 Instance Template
Launch EC2 instances with standard configuration.

```hcl
module "jenkins" {
  source = "./templates/ec2"
  
  instance_type = "t3.medium"
  ami_id        = data.aws_ami.ubuntu.id
  key_name      = aws_key_pair.deployer.key_name
  
  subnet_id            = module.vpc.public_subnet_ids[0]
  security_group_ids   = [module.security_group.id]
  iam_instance_profile = aws_iam_instance_profile.jenkins.name
  
  root_volume_size = 50
  
  tags = {
    Name = "jenkins-server"
  }
}
```

## Creating Templates

### Template Structure
```
templates/
├── vpc/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── README.md
├── ec2/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── README.md
└── security-group/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── README.md
```

### Template Guidelines

1. **Each template should be independent**
   - Use variables for all inputs
   - Don't hardcode values
   - Document all parameters

2. **Provide sensible defaults**
   - Standard instance types
   - Common port ranges
   - Typical CIDR blocks

3. **Include examples**
   - Show basic usage
   - Show advanced options
   - Document edge cases

4. **Document thoroughly**
   - Explain purpose
   - List all variables
   - Show example outputs
   - Include use cases

## Contributing Templates

To add a new template:

1. Create directory: `templates/my-template/`
2. Create files: `main.tf`, `variables.tf`, `outputs.tf`, `README.md`
3. Document all inputs and outputs
4. Add example usage
5. Test thoroughly
6. Submit PR with tests

## Template Library

### Networking
- [x] VPC with public/private subnets
- [x] Security groups
- [x] Load balancer
- [ ] VPC peering
- [ ] NAT gateway

### Compute
- [x] EC2 instances
- [x] Auto scaling groups
- [ ] ECS clusters
- [ ] Lambda functions
- [ ] Lightsail

### Data
- [x] RDS databases
- [ ] DynamoDB tables
- [ ] Elasticache
- [ ] DocumentDB
- [ ] Neptune

### Storage
- [x] S3 buckets
- [ ] EBS volumes
- [ ] EFS
- [ ] Snowball

### Monitoring
- [ ] CloudWatch dashboards
- [ ] SNS topics
- [ ] CloudWatch alarms
- [ ] Log groups

## Related Documentation
- [Template Usage Guide](./README.md)
- [Terraform Modules](../README.md)
- [Best Practices](../docs/best-practices.md)
