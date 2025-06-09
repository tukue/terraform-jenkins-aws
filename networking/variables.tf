variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
}

variable "cidr_public_subnet" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "eu_availability_zone" {
  description = "List of availability zones"
  type        = list(string)
}

variable "cidr_private_subnet" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "environment" {
  description = "Environment for the resources (e.g., dev, qa, prod)"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed for SSH access"
  type        = string
  default     = "0.0.0.0/0"  # This should be overridden with a specific IP range
}

variable "flow_logs_retention_days" {
  description = "Number of days to retain VPC flow logs"
  type        = number
  default     = 30
}