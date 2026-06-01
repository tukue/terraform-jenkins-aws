variable "domain_name" {
  type = string
}

variable "aws_lb_dns_name" {
  type = string
}

variable "aws_lb_zone_id" {
  type = string
}
variable "environment" {
  description = "Environment for the resources (e.g., dev, qa, prod)"
  type        = string
  default     = "dev" # Default to dev if not specified
}
