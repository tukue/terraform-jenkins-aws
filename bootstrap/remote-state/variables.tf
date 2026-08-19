variable "aws_profile" {
  type        = string
  description = "Optional AWS CLI profile for local bootstrap"
  default     = ""
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID that owns the Terraform state backend"

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "aws_account_id must be a 12-digit AWS account ID."
  }
}

variable "aws_region" {
  type        = string
  description = "AWS region for the state backend"
  default     = "eu-north-1"
}

variable "state_bucket_name" {
  type        = string
  description = "S3 bucket name used for Terraform remote state"
}

variable "lock_table_name" {
  type        = string
  description = "DynamoDB table name used for Terraform state locking"
  default     = "jenkins-terraform-locks"
}

variable "kms_alias_name" {
  type        = string
  description = "KMS alias name for Terraform state encryption"
  default     = "alias/terraform-encryption-key"
}

variable "environment" {
  type        = string
  description = "Environment tag for backend resources"
  default     = "shared"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags for backend resources"
  default     = {}
}
