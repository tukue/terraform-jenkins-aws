variable "aws_profile" {
  type        = string
  description = "Optional AWS CLI profile for local development"
  default     = ""
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID for this environment"

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "aws_account_id must be a 12-digit AWS account ID."
  }
}

variable "aws_region" {
  type        = string
  description = "AWS region for this environment"
  default     = "eu-north-1"
}

variable "public_key" {
  type        = string
  description = "Public key for Jenkins EC2 SSH access"
}

variable "grafana_admin_password" {
  type        = string
  description = "Grafana admin password when the Grafana EC2 service is enabled"
  sensitive   = true
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Environment-specific tags"
  default     = {}
}
