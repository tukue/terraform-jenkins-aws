variable "domain_name" {}
variable "hosted_zone_id" {}
variable "environment" {
  description = "Environment for the resources (e.g., dev, qa, prod)"
  type        = string
  default     = "dev"  # Default to dev if not specified
}