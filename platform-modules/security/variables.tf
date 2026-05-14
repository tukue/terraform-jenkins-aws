variable "ec2_sg_name" {}
variable "vpc_id" {}
variable "vpc_cidr" {
  description = "CIDR block for private egress inside the VPC"
  type        = string
}
variable "ec2_jenkins_sg_name" {}
variable "environment" {
  description = "Environment for the resources (e.g., dev, qa, prod)"
  type        = string
}

variable "allowed_ssh_cidr_blocks" {
  description = "List of CIDR blocks allowed to connect via SSH"
  type        = list(string)
  default     = [] # Empty by default, must be specified in terraform.tfvars
}

variable "allowed_http_cidr_blocks" {
  description = "List of CIDR blocks allowed to connect via HTTP/HTTPS"
  type        = list(string)
  default     = [] # Empty by default, must be specified in terraform.tfvars
}

variable "allowed_jenkins_cidr_blocks" {
  description = "List of CIDR blocks allowed to connect to Jenkins"
  type        = list(string)
  default     = [] # Empty by default, must be specified in terraform.tfvars
}

variable "allowed_jenkins_egress_cidr_blocks" {
  description = "CIDR blocks Jenkins can reach outbound. Keep VPC-only for private endpoints, or override explicitly for bootstrap egress."
  type        = list(string)
}

variable "alb_sg_name" {
  description = "Name for the public ALB security group"
  type        = string
  default     = "Allow HTTP and HTTPS to Jenkins ALB"
}

variable "allowed_alb_cidr_blocks" {
  description = "CIDR blocks allowed to reach the public Jenkins ALB on HTTP and HTTPS"
  type        = list(string)
  default     = []
}
