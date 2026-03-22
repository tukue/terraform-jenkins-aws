variable "aws_region" {
  type        = string
  default     = "eu-north-1"
  description = "AWS region"
}

variable "aws_profile" {
  type        = string
  default     = null
  description = "Optional AWS CLI profile for the target account"
}

variable "aws_account_id" {
  type        = string
  default     = ""
  description = "AWS account ID"
}

variable "customer_name" {
  type        = string
  default     = "acme"
  description = "Customer or tenant name"
}

variable "tenant_name" {
  type        = string
  default     = ""
  description = "Optional tenant display name"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment name"
}

variable "container_image" {
  type        = string
  default     = "ghcr.io/tukue/saas-ecommerce-demo:latest"
  description = "Container image"
}

variable "container_port" {
  type        = number
  default     = 8080
  description = "Container port"
}

variable "desired_count" {
  type        = number
  default     = 2
  description = "Desired task count"
}

variable "cpu" {
  type        = number
  default     = 512
  description = "Task CPU units"
}

variable "memory" {
  type        = number
  default     = 1024
  description = "Task memory in MiB"
}

variable "alb_certificate_arn" {
  type        = string
  default     = ""
  description = "Optional ACM certificate ARN"
}

variable "hosted_zone_id" {
  type        = string
  default     = ""
  description = "Optional Route 53 hosted zone ID"
}

variable "dns_name" {
  type        = string
  default     = ""
  description = "Optional DNS name"
}

variable "enable_waf" {
  type        = bool
  default     = true
  description = "Attach AWS WAF to the customer ALB"
}

variable "waf_rate_limit" {
  type        = number
  default     = 2000
  description = "WAF rate limit per 5-minute period"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags"
}
