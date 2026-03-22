variable "customer_name" {
  type        = string
  description = "Customer or tenant name"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,32}$", var.customer_name))
    error_message = "customer_name must be 3-32 characters and use lowercase letters, numbers, and hyphens."
  }
}

variable "tenant_name" {
  type        = string
  default     = ""
  description = "Optional tenant display name used for naming and tagging"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, qa, prod)"

  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "Environment must be dev, qa, or prod."
  }
}

variable "aws_region" {
  type        = string
  default     = "eu-north-1"
  description = "AWS region for the customer runtime"
}

variable "aws_account_id" {
  type        = string
  default     = ""
  description = "AWS account ID where the runtime is provisioned"
}

variable "network_profile" {
  type        = string
  default     = "standard"
  description = "Regional landing zone profile used to resolve network defaults"
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "VPC ID for the customer runtime"
}

variable "public_subnet_ids" {
  type        = list(string)
  default     = []
  description = "Public subnet IDs for the application load balancer"
}

variable "private_subnet_ids" {
  type        = list(string)
  default     = []
  description = "Private subnet IDs for ECS tasks"
}

variable "container_image" {
  type        = string
  default     = "ghcr.io/tukue/saas-ecommerce-demo:latest"
  description = "Container image for the customer service"
}

variable "container_port" {
  type        = number
  default     = 8080
  description = "Container port exposed by the application"
}

variable "cpu" {
  type        = number
  default     = 512
  description = "Fargate CPU units"
}

variable "memory" {
  type        = number
  default     = 1024
  description = "Fargate memory in MiB"
}

variable "desired_count" {
  type        = number
  default     = 2
  description = "Desired number of running tasks"
}

variable "health_check_path" {
  type        = string
  default     = "/health"
  description = "HTTP health check path"
}

variable "alb_certificate_arn" {
  type        = string
  default     = ""
  description = "Optional ACM certificate ARN for HTTPS"
}

variable "hosted_zone_id" {
  type        = string
  default     = ""
  description = "Optional Route 53 hosted zone ID"
}

variable "dns_name" {
  type        = string
  default     = ""
  description = "Optional DNS record name for the customer runtime"
}

variable "tenant_domain" {
  type        = string
  default     = ""
  description = "Optional tenant DNS name for the runtime"
}

variable "task_environment" {
  type        = map(string)
  default     = {}
  description = "Environment variables injected into the application container"
}

variable "task_secrets" {
  type        = map(string)
  default     = {}
  description = "Secrets injected into the application container"
}

variable "assign_public_ip" {
  type        = bool
  default     = false
  description = "Whether ECS tasks should receive public IPs"
}

variable "enable_execute_command" {
  type        = bool
  default     = true
  description = "Enable ECS Exec for the service"
}

variable "alb_internal" {
  type        = bool
  default     = false
  description = "Whether the load balancer is internal"
}

variable "enable_waf" {
  type        = bool
  default     = true
  description = "Attach an AWS WAF web ACL to the application load balancer"
}

variable "waf_rate_limit" {
  type        = number
  default     = 2000
  description = "Request rate limit per 5-minute window for the WAF rule"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional resource tags"
}
