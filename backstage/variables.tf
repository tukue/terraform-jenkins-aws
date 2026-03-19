variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, qa, prod)"

  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "Environment must be dev, qa, or prod."
  }
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC CIDR block"
}

variable "enable_nat" {
  type        = bool
  default     = true
  description = "Enable NAT Gateway for private subnets"
}

# Database variables
variable "db_password" {
  type        = string
  description = "RDS master password"
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 8
    error_message = "Password must be at least 8 characters."
  }
}

variable "db_allocated_storage" {
  type        = number
  default     = 100
  description = "RDS allocated storage in GB"
}

variable "db_instance_class" {
  type        = string
  default     = "db.t3.medium"
  description = "RDS instance class"
}

variable "db_backup_retention" {
  type        = number
  default     = 30
  description = "RDS backup retention in days"
}

# EC2 variables
variable "instance_type" {
  type        = string
  default     = "t3.large"
  description = "EC2 instance type for Backstage"
}

variable "root_volume_size" {
  type        = number
  default     = 100
  description = "Root volume size in GB"
}

variable "key_name" {
  type        = string
  description = "SSH key pair name"
  default     = ""
}

# GitHub integration
variable "github_client_id" {
  type        = string
  description = "GitHub OAuth2 Client ID"
  sensitive   = true
}

variable "github_client_secret" {
  type        = string
  description = "GitHub OAuth2 Client Secret"
  sensitive   = true
}

variable "github_token" {
  type        = string
  description = "GitHub Personal Access Token for catalog discovery"
  sensitive   = true
}

variable "backstage_version" {
  type        = string
  default     = "latest"
  description = "Backstage Docker image version"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional resource tags"
}
