variable "aws_account_id" {
  type        = string
  description = "AWS account ID that owns both regional clusters"
}

variable "aws_profile" {
  type        = string
  default     = null
  description = "Optional AWS CLI profile for local portfolio demonstrations"
}

variable "primary_region" {
  type        = string
  description = "Region serving normal application traffic"
}

variable "standby_region" {
  type        = string
  description = "Region hosting the warm standby cluster"

  validation {
    condition     = var.standby_region != var.primary_region
    error_message = "standby_region must differ from primary_region."
  }
}

variable "cluster_name" {
  type        = string
  description = "Shared cluster name prefix"
  default     = "portfolio-dr"
}

variable "environment" {
  type        = string
  description = "Platform environment"
  default     = "dev"
}

variable "kubernetes_version" {
  type        = string
  description = "EKS version for both regions"
  default     = "1.31"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags applied to both regional clusters"
}
