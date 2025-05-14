variable "domain_name" {
  type        = string
  description = "Domain name to register"
}

variable "admin_contact" {
  type = object({
    first_name         = string
    last_name          = string
    email             = string
    phone_number      = string
    address_line_1    = string
    city              = string
    state             = string
    zip_code          = string
    country_code      = string
  })
  description = "Administrative contact information for the domain"
}

variable "environment" {
  description = "Environment for the resources (e.g., dev, qa, prod)"
  type        = string
  default     = "dev"  # Default to dev if not specified
}