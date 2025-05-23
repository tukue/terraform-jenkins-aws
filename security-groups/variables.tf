variable "ec2_sg_name" {}
variable "vpc_id" {}
variable "ec2_jenkins_sg_name" {}
variable "environment" {
  description = "Environment for the resources (e.g., dev, qa, prod)"
  type        = string
}