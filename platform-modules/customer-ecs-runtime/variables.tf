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

variable "create_ecr_repository" {
  type        = bool
  default     = true
  description = "Create an ECR repository for the customer runtime image"
}

variable "ecr_repository_name" {
  type        = string
  default     = ""
  description = "Optional ECR repository name override"
}

variable "ecr_image_tag_mutability" {
  type        = string
  default     = "IMMUTABLE"
  description = "Whether image tags in ECR can be overwritten"

  validation {
    condition     = contains(["IMMUTABLE", "MUTABLE"], var.ecr_image_tag_mutability)
    error_message = "ecr_image_tag_mutability must be IMMUTABLE or MUTABLE."
  }
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

  validation {
    condition     = var.desired_count > 0
    error_message = "desired_count must be greater than 0."
  }
}

variable "enable_autoscaling" {
  type        = bool
  default     = true
  description = "Enable ECS service autoscaling"
}

variable "autoscaling_min_capacity" {
  type        = number
  default     = null
  description = "Optional override for the minimum ECS task count when autoscaling is enabled"

  validation {
    condition     = var.autoscaling_min_capacity == null || var.autoscaling_min_capacity > 0
    error_message = "autoscaling_min_capacity must be greater than 0 when provided."
  }
}

variable "autoscaling_max_capacity" {
  type        = number
  default     = null
  description = "Optional override for the maximum ECS task count when autoscaling is enabled"
}

variable "autoscaling_cpu_target" {
  type        = number
  default     = null
  description = "Optional override for the target average CPU utilization percentage"

  validation {
    condition     = var.autoscaling_cpu_target == null || (var.autoscaling_cpu_target > 0 && var.autoscaling_cpu_target <= 100)
    error_message = "autoscaling_cpu_target must be between 1 and 100 when provided."
  }
}

variable "autoscaling_memory_target" {
  type        = number
  default     = null
  description = "Optional override for the target average memory utilization percentage"

  validation {
    condition     = var.autoscaling_memory_target == null || (var.autoscaling_memory_target > 0 && var.autoscaling_memory_target <= 100)
    error_message = "autoscaling_memory_target must be between 1 and 100 when provided."
  }
}

variable "autoscaling_request_target" {
  type        = number
  default     = null
  description = "Optional override for the target ALB request count per target"

  validation {
    condition     = var.autoscaling_request_target == null || var.autoscaling_request_target > 0
    error_message = "autoscaling_request_target must be greater than 0 when provided."
  }
}

variable "autoscaling_scale_in_cooldown" {
  type        = number
  default     = null
  description = "Optional override for the cooldown in seconds before scaling in again"
}

variable "autoscaling_scale_out_cooldown" {
  type        = number
  default     = null
  description = "Optional override for the cooldown in seconds before scaling out again"
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

variable "redirect_http_to_https" {
  type        = bool
  default     = true
  description = "Redirect HTTP traffic to HTTPS when a certificate is configured"
}

variable "alb_ssl_policy" {
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  description = "TLS security policy for the HTTPS listener"
}

variable "alb_ingress_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "CIDR blocks allowed to reach the ALB listeners"
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

variable "health_check_grace_period_seconds" {
  type        = number
  default     = 60
  description = "Grace period before ECS health checks affect task replacement"
}

variable "deployment_minimum_healthy_percent" {
  type        = number
  default     = 50
  description = "Lower bound of healthy tasks during deployments"
}

variable "deployment_maximum_percent" {
  type        = number
  default     = 200
  description = "Upper bound of running tasks during deployments"
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
