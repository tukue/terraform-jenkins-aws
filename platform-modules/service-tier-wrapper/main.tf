variable "service_name" {
  type        = string
  description = "Name of the service"
}

variable "tier" {
  type        = string
  description = "Service tier (small, med, large)"
  validation {
    condition     = contains(["small", "med", "large"], var.tier)
    error_message = "Tier must be small, med, or large."
  }
}

variable "container_image" {
  type        = string
  description = "Docker image to deploy"
}

variable "environment" {
  type        = string
  description = "Environment (dev, qa, prod)"
}

locals {
  tier_configs = {
    small = { cpu = 256, memory = 512,  desired = 1, waf = 1000 }
    med   = { cpu = 512, memory = 1024, desired = 2, waf = 2000 }
    large = { cpu = 1024, memory = 2048, desired = 3, waf = 5000 }
  }
  config = local.tier_configs[var.tier]
}

module "ecs_runtime" {
  source          = "../customer-ecs-runtime"
  customer_name   = var.service_name
  environment     = var.environment
  container_image = var.container_image
  cpu             = local.config.cpu
  memory          = local.config.memory
  desired_count   = local.config.desired
  enable_waf      = true
  waf_rate_limit  = local.config.waf
}
