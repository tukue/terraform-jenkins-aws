variable "domain_name" {
  type = string
}

variable "hosted_zone_id" {
  type = string
}
variable "environment" {
  description = "Environment for the resources (e.g., dev, qa, prod)"
  type        = string
  default     = "dev" # Default to dev if not specified
}
