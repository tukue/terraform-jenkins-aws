variable "ec2_sg_name" {}
variable "vpc_id" {}
variable "ec2_jenkins_sg_name" {}
variable "environment" {
  description = "Environment for the resources (e.g., dev, qa, prod)"
  type        = string
}

variable "allowed_ssh_cidr_blocks" {
  description = "List of CIDR blocks allowed to connect via SSH"
  type        = list(string)
  default     = []  # Empty by default, must be specified in terraform.tfvars
}

variable "allowed_http_cidr_blocks" {
  description = "List of CIDR blocks allowed to connect via HTTP/HTTPS"
  type        = list(string)
  default     = []  # Empty by default, must be specified in terraform.tfvars
}

variable "allowed_jenkins_cidr_blocks" {
  description = "List of CIDR blocks allowed to connect to Jenkins"
  type        = list(string)
  default     = []  # Empty by default, must be specified in terraform.tfvars
}