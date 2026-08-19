variable "bucket_name" {
  type        = string
  description = "Remote state bucket name"
}

variable "vpc_cidr" {
  type        = string
  description = "Public Subnet CIDR values"
}

variable "vpc_name" {
  type        = string
  description = "DevOps Project 1 VPC 1"
}

variable "cidr_public_subnet" {
  type        = list(string)
  description = "Public Subnet CIDR values"
}

variable "cidr_private_subnet" {
  type        = list(string)
  description = "Private Subnet CIDR values"
}

variable "eu_availability_zone" {
  type        = list(string)
  description = "Availability Zones"
}

variable "public_key" {
  type        = string
  description = "DevOps Project 1 Public key for EC2 instance"
}

variable "ec2_ami_id" {
  type        = string
  description = "DevOps Project 1 AMI Id for EC2 instance"
}

variable "environment" {
  type        = string
  description = "The environment for the workspace (e.g., dev, QA, production)"
  default     = "dev"
}

variable "run_ansible" {
  description = "Whether to run Ansible configuration after provisioning"
  type        = bool
  default     = false
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version approved for this platform"
  type        = string
}

variable "eks_public_access_cidrs" {
  description = "CIDRs permitted to reach the EKS public API endpoint"
  type        = list(string)
}

variable "eks_node_instance_types" {
  description = "Instance types for the managed EKS node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_node_desired_size" {
  description = "Initial EKS worker-node count"
  type        = number
  default     = 2
}

variable "eks_node_min_size" {
  description = "Minimum EKS worker-node count"
  type        = number
  default     = 2
}

variable "eks_node_max_size" {
  description = "Maximum EKS worker-node count"
  type        = number
  default     = 4
}

variable "cicd_principal_arn" {
  description = "Optional IAM role ARN used by CI to deploy applications to EKS"
  type        = string
  default     = null
}
