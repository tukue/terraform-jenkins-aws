variable "bucket_name" {
  type        = string
  description = "Remote state bucket name"
}

variable "aws_profile" {
  type        = string
  description = "Optional AWS CLI profile for local development"
  default     = ""
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID for the target environment"

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "aws_account_id must be a 12-digit AWS account ID."
  }
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
  description = "Optional AMI ID for the Jenkins EC2 instance; defaults to the latest Ubuntu LTS image"
  default     = ""
}

variable "environment" {
  type        = string
  description = "The environment for the workspace (e.g., dev, QA, production)"
  default     = "dev"

  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "Environment must be dev, qa, or prod."
  }
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for the Jenkins server"
  default     = "t3.small"
}

variable "enable_nat_gateway" {
  description = "Create NAT gateway egress for private subnets so Jenkins can install and update packages"
  type        = bool
  default     = true
}

variable "jenkins_port" {
  description = "Port Jenkins listens on inside the private subnet"
  type        = number
  default     = 8080
}

variable "alb_certificate_arn" {
  description = "Optional ACM certificate ARN for HTTPS on the Jenkins ALB. If empty, the ALB serves HTTP."
  type        = string
  default     = ""
}

variable "allowed_alb_cidr_blocks" {
  description = "CIDR blocks allowed to reach the public Jenkins ALB on HTTP and HTTPS"
  type        = list(string)
  default     = []
}

variable "allowed_jenkins_egress_cidr_blocks" {
  description = "CIDR blocks Jenkins can reach outbound. Defaults to VPC-only when empty."
  type        = list(string)
  default     = []
}

variable "enable_waf" {
  description = "Attach a regional AWS WAFv2 Web ACL to the Jenkins ALB"
  type        = bool
  default     = true
}

variable "waf_rate_limit" {
  description = "Maximum requests per 5-minute period from a single IP before WAF blocks it"
  type        = number
  default     = 2000
}

variable "run_ansible" {
  description = "Whether to run Ansible configuration after provisioning"
  type        = bool
  default     = false
}

variable "enable_observability" {
  description = "Enable the managed Prometheus, CloudWatch monitoring, and OpenTelemetry observability stack"
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

variable "tags" {
  description = "Additional tags applied by modules that support them"
  type        = map(string)
  default     = {}
}
