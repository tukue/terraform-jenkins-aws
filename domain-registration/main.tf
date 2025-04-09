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

# Register the domain
resource "aws_route53domains_registered_domain" "domain" {
  domain_name = var.domain_name

  dynamic "name_server" {
    for_each = aws_route53_zone.primary.name_servers
    content {
      name = name_server.value
    }
  }

  admin_contact {
    first_name         = var.admin_contact.first_name
    last_name          = var.admin_contact.last_name
    email             = var.admin_contact.email
    phone_number      = var.admin_contact.phone_number
    address_line_1    = var.admin_contact.address_line_1
    city              = var.admin_contact.city
    state             = var.admin_contact.state
    zip_code          = var.admin_contact.zip_code
    country_code      = var.admin_contact.country_code
  }

  # Registrant and Tech contact usually match admin contact
  registrant_contact {
    first_name         = var.admin_contact.first_name
    last_name          = var.admin_contact.last_name
    email             = var.admin_contact.email
    phone_number      = var.admin_contact.phone_number
    address_line_1    = var.admin_contact.address_line_1
    city              = var.admin_contact.city
    state             = var.admin_contact.state
    zip_code          = var.admin_contact.zip_code
    country_code      = var.admin_contact.country_code
  }

  tech_contact {
    first_name         = var.admin_contact.first_name
    last_name          = var.admin_contact.last_name
    email             = var.admin_contact.email
    phone_number      = var.admin_contact.phone_number
    address_line_1    = var.admin_contact.address_line_1
    city              = var.admin_contact.city
    state             = var.admin_contact.state
    zip_code          = var.admin_contact.zip_code
    country_code      = var.admin_contact.country_code
  }

  # Auto renew the domain
  auto_renew = true

  # Privacy protection
  admin_privacy      = true
  registrant_privacy = true
  tech_privacy       = true
}

# Create the hosted zone
resource "aws_route53_zone" "primary" {
  name = var.domain_name
  
  tags = {
    Environment = "production"
    Terraform   = "true"
  }
}

output "domain_id" {
  value = aws_route53domains_registered_domain.domain.id
}

output "hosted_zone_id" {
  value = aws_route53_zone.primary.zone_id
}

output "name_servers" {
  value = aws_route53_zone.primary.name_servers
}