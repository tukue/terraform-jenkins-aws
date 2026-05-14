# Map instance size names to AWS instance types
locals {
  instance_type_map = {
    micro  = "t3.micro"
    small  = "t3.small"
    medium = "t3.medium"
    large  = "t3.large"
    xlarge = "t3.xlarge"
  }

  instance_type = local.instance_type_map[var.instance_size]

  # Get AZs if not provided
  azs = length(var.availability_zones) > 0 ? var.availability_zones : slice(data.aws_availability_zones.available.names, 0, 2)

  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform-platform-module"
    }
  )
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Delegate to main Jenkins infrastructure
# This module wraps the existing root module with platform-friendly defaults
module "jenkins_infrastructure" {
  source = "../../" # Reference the root module

  # Basic settings
  environment = var.environment
  aws_region  = var.aws_region
  aws_profile = var.aws_profile
  aws_account_id = var.aws_account_id
  bucket_name = var.bucket_name

  # Naming
  vpc_name = "${var.project_name}-vpc"

  # Networking
  vpc_cidr             = var.vpc_cidr
  cidr_public_subnet   = [cidrsubnet(var.vpc_cidr, 4, 1), cidrsubnet(var.vpc_cidr, 4, 2)]
  cidr_private_subnet  = [cidrsubnet(var.vpc_cidr, 4, 11), cidrsubnet(var.vpc_cidr, 4, 12)]
  eu_availability_zone = local.azs
  enable_nat_gateway   = var.enable_nat_gateway

  # EC2 Configuration
  ec2_ami_id          = data.aws_ami.latest_ubuntu.id
  instance_type       = local.instance_type
  public_key          = var.public_key
  run_ansible         = var.ansible_enabled
  alb_certificate_arn                 = var.alb_certificate_arn
  allowed_alb_cidr_blocks            = var.allowed_alb_cidr_blocks
  allowed_jenkins_egress_cidr_blocks = var.allowed_jenkins_egress_cidr_blocks
  enable_waf                          = var.enable_waf
  waf_rate_limit                      = var.waf_rate_limit

  # Tagging
  tags = local.common_tags
}

# Get latest Ubuntu AMI
data "aws_ami" "latest_ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
