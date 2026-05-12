variable "name" {
  description = "Name of the security group"
  type        = string
}

variable "description" {
  description = "Description of the security group"
  type        = string
  default     = "Managed by Terraform"
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string

  validation {
    condition     = can(regex("^vpc-([a-f0-9]{8}|[a-f0-9]{17})$", var.vpc_id))
    error_message = "vpc_id must be a valid AWS VPC ID such as vpc-1234abcd or vpc-1234567890abcdef0."
  }
}

variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    description      = string
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = list(string)
    security_groups  = list(string)
    self             = bool
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.ingress_rules :
      length(rule.cidr_blocks) > 0 || length(rule.security_groups) > 0 || rule.self
    ])
    error_message = "Each ingress rule must specify at least one cidr_blocks entry, security_groups entry, or self = true."
  }

  validation {
    condition = alltrue(flatten([
      for rule in var.ingress_rules : [
        for cidr in rule.cidr_blocks :
        can(cidrhost(cidr, 0))
      ]
    ]))
    error_message = "Each ingress cidr_blocks entry must be a valid CIDR block."
  }

  validation {
    condition = alltrue(flatten([
      for rule in var.ingress_rules : [
        for cidr in rule.cidr_blocks :
        !contains(["0.0.0.0/0", "::/0"], cidr)
      ]
    ]))
    error_message = "Ingress rules must not use unrestricted CIDRs such as 0.0.0.0/0 or ::/0."
  }

  validation {
    condition = alltrue(flatten([
      for rule in var.ingress_rules : [
        for security_group in rule.security_groups :
        can(regex("^sg-([a-f0-9]{8}|[a-f0-9]{17})$", security_group))
      ]
    ]))
    error_message = "Each ingress security_groups entry must be a valid AWS security group ID."
  }
}

variable "egress_rules" {
  description = "List of egress rules"
  type = list(object({
    description      = string
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = list(string)
    security_groups  = list(string)
    self             = bool
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.egress_rules :
      length(rule.cidr_blocks) > 0 || length(rule.security_groups) > 0 || rule.self
    ])
    error_message = "Each egress rule must specify at least one cidr_blocks entry, security_groups entry, or self = true."
  }

  validation {
    condition = alltrue(flatten([
      for rule in var.egress_rules : [
        for cidr in rule.cidr_blocks :
        can(cidrhost(cidr, 0))
      ]
    ]))
    error_message = "Each egress cidr_blocks entry must be a valid CIDR block."
  }

  validation {
    condition = alltrue(flatten([
      for rule in var.egress_rules : [
        for security_group in rule.security_groups :
        can(regex("^sg-([a-f0-9]{8}|[a-f0-9]{17})$", security_group))
      ]
    ]))
    error_message = "Each egress security_groups entry must be a valid AWS security group ID."
  }
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
