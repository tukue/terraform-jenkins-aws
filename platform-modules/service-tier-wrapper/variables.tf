variable "service_name" {
  type        = string
  description = "Service name used for naming and tagging"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,32}$", var.service_name))
    error_message = "service_name must be 3-32 characters and use lowercase letters, numbers, and hyphens."
  }
}

variable "tenant_name" {
  type        = string
  default     = ""
  description = "Optional tenant display name override"
}

variable "tier" {
  type        = string
  description = "Service tier preset"

  validation {
    condition     = contains(["small", "med", "large"], var.tier)
    error_message = "tier must be small, med, or large."
  }
}

variable "container_image" {
  type        = string
  description = "Container image to deploy"
}

variable "environment" {
  type        = string
  description = "Target environment for the service"

  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "environment must be dev, qa, or prod."
  }
}

variable "aws_region" {
  type        = string
  default     = "eu-north-1"
  description = "AWS region for the wrapped ECS runtime"
}

variable "aws_account_id" {
  type        = string
  default     = ""
  description = "Optional AWS account ID for the wrapped ECS runtime"
}

variable "network_profile" {
  type        = string
  default     = "standard"
  description = "Landing-zone profile used to resolve default networking"
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "Optional VPC ID override"
}

variable "public_subnet_ids" {
  type        = list(string)
  default     = []
  description = "Optional public subnet IDs for the load balancer"
}

variable "private_subnet_ids" {
  type        = list(string)
  default     = []
  description = "Optional private subnet IDs for ECS tasks"
}

variable "container_port" {
  type        = number
  default     = 8080
  description = "Container port exposed by the service"
}

variable "health_check_path" {
  type        = string
  default     = "/health"
  description = "Health check path used by the load balancer"
}

variable "hosted_zone_id" {
  type        = string
  default     = ""
  description = "Optional Route 53 hosted zone ID"
}

variable "dns_name" {
  type        = string
  default     = ""
  description = "Optional DNS record name for the service"
}

variable "tenant_domain" {
  type        = string
  default     = ""
  description = "Optional tenant domain used for DNS and tagging metadata"
}

variable "task_environment" {
  type        = map(string)
  default     = {}
  description = "Environment variables injected into the service container"
}

variable "task_secrets" {
  type        = map(string)
  default     = {}
  description = "Secrets injected into the service container"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional resource tags merged with wrapper defaults"
}
