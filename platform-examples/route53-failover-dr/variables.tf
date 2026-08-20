variable "aws_account_id" {
  type        = string
  description = "AWS account ID that owns the Route 53 hosted zone"
}

variable "aws_profile" {
  type        = string
  default     = null
  description = "Optional AWS CLI profile for local execution"
}

variable "hosted_zone_id" {
  type        = string
  description = "Route 53 public hosted-zone ID for the application DNS name"
}

variable "record_name" {
  type        = string
  description = "Fully qualified application DNS name managed by Route 53"
}

variable "primary_endpoint" {
  type = object({
    record_name = string
    dns_name    = string
    zone_id     = string
  })
  description = "Primary regional DNS name, application load balancer DNS name, and canonical hosted-zone ID"
}

variable "standby_endpoint" {
  type = object({
    record_name = string
    dns_name    = string
    zone_id     = string
  })
  description = "Standby regional DNS name, application load balancer DNS name, and canonical hosted-zone ID"
}

variable "health_check_path" {
  type        = string
  default     = "/healthz"
  description = "HTTP path used to evaluate each regional endpoint"

  validation {
    condition     = startswith(var.health_check_path, "/")
    error_message = "health_check_path must start with a slash."
  }
}

variable "health_check_port" {
  type        = number
  default     = 443
  description = "Public HTTPS port exposed by each regional endpoint"
}
