variable "environment" {
  type        = string
  description = "Environment name (dev, qa, prod)"

  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "Environment must be dev, qa, or prod."
  }
}

variable "project_name" {
  type        = string
  description = "Project name for resource naming"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,20}$", var.project_name))
    error_message = "Project name must be lowercase alphanumeric with hyphens, max 20 chars."
  }
}

variable "instance_size" {
  type        = string
  default     = "medium"
  description = "Instance size: micro, small, medium, large, xlarge"

  validation {
    condition     = contains(["micro", "small", "medium", "large", "xlarge"], var.instance_size)
    error_message = "Instance size must be micro, small, medium, large, or xlarge."
  }
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC CIDR block"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid CIDR notation."
  }
}

variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "availability_zones" {
  type        = list(string)
  default     = []
  description = "List of availability zones (auto-selected if empty)"
}

variable "enable_nat_gateway" {
  type        = bool
  default     = true
  description = "Enable NAT Gateway for private subnets"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags"
}

variable "enable_monitoring" {
  type        = bool
  default     = true
  description = "Enable CloudWatch monitoring"
}

variable "ansible_enabled" {
  type        = bool
  default     = true
  description = "Run Ansible configuration on EC2"
}

variable "public_key" {
  type        = string
  description = "SSH public key for EC2 instance access"
}
