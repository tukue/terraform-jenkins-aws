variable "aws_account_id" {
  type        = string
  description = "AWS account ID that owns the source and destination registries"
}

variable "aws_profile" {
  type        = string
  default     = null
  description = "Optional AWS CLI profile for local portfolio demonstrations"
}

variable "source_region" {
  type        = string
  description = "Region containing the source ECR registry"
}

variable "destination_region" {
  type        = string
  description = "Region receiving replicated images"

  validation {
    condition     = var.destination_region != var.source_region
    error_message = "destination_region must differ from source_region."
  }
}

variable "repository_prefix" {
  type        = string
  description = "ECR repository prefix replicated to the standby Region"
  default     = "platform-"
}
