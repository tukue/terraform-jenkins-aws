variable "lb_name" {
  type = string
}

variable "lb_type" {
  type = string
}

variable "is_external" {
  type    = bool
  default = false
}

variable "sg_enable_ssh_https" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "tag_name" {
  type = string
}

variable "lb_target_group_arn" {
  type = string
}

variable "ec2_instance_id" {
  type = string
}

variable "lb_listner_port" {
  type = number
}

variable "lb_listner_protocol" {
  type = string
}

variable "lb_listner_default_action" {
  type = string
}

variable "lb_https_listner_port" {
  type = number
}

variable "lb_https_listner_protocol" {
  type = string
}

variable "dev_proj_1_acm_arn" {
  type = string
}

variable "lb_target_group_attachment_port" {
  type = number
}
variable "environment" {
  description = "Environment for the resources (e.g., dev, qa, prod)"
  type        = string
  default     = "dev" # Default to dev if not specified
}
