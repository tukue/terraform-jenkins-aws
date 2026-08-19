variable "service_name" {
  type        = string
  description = "Service name used for naming and tagging"
}

variable "environment" {
  type        = string
  description = "Target environment for the service"
}

variable "tier" {
  type        = string
  description = "Supported service tier preset"
}

variable "container_image" {
  type        = string
  description = "Container image to deploy"
}

variable "aws_region" {
  type        = string
  description = "AWS region used for the service deployment"
  default     = "eu-north-1"
}

variable "aws_account_id" {
  type        = string
  description = "Optional AWS account ID for guardrail validation"
  default     = ""
}

variable "network_profile" {
  type        = string
  description = "Landing-zone profile used to resolve network defaults"
  default     = "standard"
}

variable "dns_name" {
  type        = string
  description = "Optional DNS name for the service"
  default     = ""
}

variable "hosted_zone_id" {
  type        = string
  description = "Optional Route 53 hosted zone ID for the service record"
  default     = ""
}

variable "task_environment" {
  type        = map(string)
  description = "Environment variables injected into the service container"
  default     = {}
}

variable "task_secrets" {
  type        = map(string)
  description = "Secrets injected into the service container"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Additional tags merged with platform defaults"
  default     = {}
}
