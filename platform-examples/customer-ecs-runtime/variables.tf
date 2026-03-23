variable "aws_region" {
  type        = string
  default     = "eu-north-1"
  description = "AWS region"

  validation {
    condition = contains([
      "us-east-1",
      "us-east-2",
      "us-west-2",
      "eu-north-1",
      "eu-west-1",
      "me-south-1",
      "ap-southeast-1",
      "ap-southeast-2",
      "sa-east-1"
    ], var.aws_region)
    error_message = "aws_region must be one of the approved platform regions."
  }
}

variable "aws_profile" {
  type        = string
  default     = null
  description = "Optional AWS CLI profile for the target account"
}

variable "aws_account_id" {
  type        = string
  default     = "123456789012"
  description = "AWS account ID"

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "aws_account_id must be a 12-digit AWS account ID."
  }
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

variable "enable_autoscaling" {
  type        = bool
  default     = true
  description = "Enable ECS service autoscaling in the selected AWS account and region"
}

variable "autoscaling_min_capacity" {
  type        = number
  default     = null
  description = "Optional override for the minimum ECS task count"
}

variable "autoscaling_max_capacity" {
  type        = number
  default     = null
  description = "Optional override for the maximum ECS task count"
}

variable "autoscaling_cpu_target" {
  type        = number
  default     = null
  description = "Optional override for the target CPU utilization percentage"
}

variable "autoscaling_memory_target" {
  type        = number
  default     = null
  description = "Optional override for the target memory utilization percentage"
}

variable "autoscaling_request_target" {
  type        = number
  default     = null
  description = "Optional override for the target ALB request count per target"
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

variable "redirect_http_to_https" {
  type        = bool
  default     = true
  description = "Redirect HTTP traffic to HTTPS when a certificate is configured"
}

variable "alb_ingress_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "CIDR blocks allowed to reach the ALB"
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
