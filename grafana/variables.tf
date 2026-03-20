variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "ami_id" {
  description = "AMI ID used for the Grafana host"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for Grafana"
  type        = string
  default     = "t3.small"
}

variable "subnet_id" {
  description = "Subnet ID for the Grafana host"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID used for the Grafana security group"
  type        = string
}

variable "allowed_cidrs" {
  description = "CIDR blocks allowed to access Grafana"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "prometheus_url" {
  description = "Prometheus URL used as the Grafana datasource"
  type        = string
  default     = "http://localhost:9090"
}

variable "admin_user" {
  description = "Grafana admin username"
  type        = string
  default     = "admin"
}

variable "admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

variable "grafana_version" {
  description = "Grafana Docker image tag"
  type        = string
  default     = "11.2.0"
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
