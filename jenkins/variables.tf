variable "ami_id" {
  type        = string
  description = "The AMI ID for the Jenkins EC2 instance"
}

variable "instance_type" {
  type        = string
  description = "The instance type for the Jenkins EC2 instance"
}

variable "tag_name" {
  type        = string
  description = "The tag name for the Jenkins EC2 instance"
}

variable "public_key" {
  type        = string
  description = "The public key for the Jenkins EC2 instance"
}

variable "subnet_id" {
  type        = string
  description = "The subnet ID where the Jenkins EC2 instance will be deployed"
}

variable "sg_for_jenkins" {
  type        = list(string)
  description = "The security group IDs for the Jenkins EC2 instance"
}

variable "enable_public_ip_address" {
  type        = bool
  description = "Whether to enable a public IP address for the Jenkins EC2 instance"
}

variable "user_data_install_jenkins" {
  type        = string
  description = "The user data script to install Jenkins on the EC2 instance"
}

variable "environment" {
  type        = string
  description = "The environment for the Jenkins EC2 instance (e.g., dev, QA, production)"
}

variable "run_ansible" {
  description = "Whether to run Ansible configuration after provisioning"
  type        = bool
  default     = false
}