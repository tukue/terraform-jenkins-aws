variable "bucket_name" {
  type        = string
  description = "Remote state bucket name"
}

variable "aws_region" {
  type        = string
  description = "AWS region used by the provider"
  default     = "eu-north-1"
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

variable "enable_observability" {
  description = "Enable the managed Prometheus and OpenTelemetry observability module"
  type        = bool
  default     = false
}

variable "observability_workspace_alias" {
  description = "Workspace alias for the managed Prometheus observability module"
  type        = string
  default     = "jenkins-platform-observability"
}

variable "observability_jenkins_targets" {
  description = "Static targets to scrape by OpenTelemetry Collector for Jenkins metrics"
  type        = list(string)
  default     = ["localhost:8080"]
}

variable "enable_grafana_service" {
  description = "Enable the self-hosted Grafana service module on AWS"
  type        = bool
  default     = false
}

variable "grafana_instance_type" {
  description = "EC2 instance type for the Grafana service"
  type        = string
  default     = "t3.small"
}

variable "grafana_prometheus_url" {
  description = "Prometheus URL used by the Grafana service"
  type        = string
  default     = "http://localhost:9090"
}

variable "grafana_admin_user" {
  description = "Grafana admin username"
  type        = string
  default     = "admin"
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
  default     = "change-me"
}

variable "grafana_allowed_cidrs" {
  description = "CIDR blocks allowed to access Grafana"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
