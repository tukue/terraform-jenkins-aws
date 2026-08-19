variable "aws_region" {
  type        = string
  description = "AWS region used by the provider"
  default     = "eu-north-1"
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID for the target environment"

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "aws_account_id must be a 12-digit AWS account ID."
  }
}

variable "environment" {
  type        = string
  description = "Environment name"

  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "Environment must be dev, qa, or prod."
  }
}

variable "project_name" {
  type        = string
  description = "Project tag value applied to platform resources"
  default     = "Jenkins-AWS"
}

variable "owner" {
  type        = string
  description = "Owner tag value applied to platform resources"
  default     = "platform-team"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
}

variable "vpc_name" {
  type        = string
  description = "VPC name"
}

variable "cidr_public_subnet" {
  type        = list(string)
  description = "Public subnet CIDR blocks"
}

variable "cidr_private_subnet" {
  type        = list(string)
  description = "Private subnet CIDR blocks"
}

variable "eu_availability_zone" {
  type        = list(string)
  description = "Availability zones"
}

variable "public_key" {
  type        = string
  description = "Public key for Jenkins EC2 SSH access"
}

variable "ec2_ami_id" {
  type        = string
  description = "Optional AMI ID for Jenkins; defaults to the latest Ubuntu LTS image"
  default     = ""
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for Jenkins"
  default     = "t3.small"
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Create NAT gateway egress for private subnets"
  default     = true
}

variable "jenkins_port" {
  type        = number
  description = "Port Jenkins listens on inside the private subnet"
  default     = 8080
}

variable "alb_certificate_arn" {
  type        = string
  description = "Optional ACM certificate ARN for HTTPS on the Jenkins ALB"
  default     = ""
}

variable "allowed_alb_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks allowed to reach the public Jenkins ALB"
  default     = []
}

variable "allowed_jenkins_egress_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks Jenkins can reach outbound. Defaults to VPC-only when empty."
  default     = []
}

variable "enable_waf" {
  type        = bool
  description = "Attach a regional AWS WAFv2 Web ACL to the Jenkins ALB"
  default     = true
}

variable "waf_rate_limit" {
  type        = number
  description = "Maximum requests per 5-minute period from a single IP before WAF blocks it"
  default     = 2000
}

variable "run_ansible" {
  type        = bool
  description = "Whether to run Ansible configuration after provisioning"
  default     = false
}

variable "enable_observability" {
  type        = bool
  description = "Enable managed Prometheus and CloudWatch monitoring"
  default     = false
}

variable "observability_workspace_alias" {
  type        = string
  description = "Workspace alias for the managed Prometheus observability module"
  default     = "jenkins-platform-observability"
}

variable "observability_jenkins_targets" {
  type        = list(string)
  description = "Static targets to scrape for Jenkins metrics"
  default     = ["localhost:8080"]
}

variable "enable_grafana_service" {
  type        = bool
  description = "Enable the self-hosted Grafana service module on AWS"
  default     = false
}

variable "grafana_instance_type" {
  type        = string
  description = "EC2 instance type for Grafana"
  default     = "t3.small"
}

variable "grafana_prometheus_url" {
  type        = string
  description = "Prometheus URL used by Grafana"
  default     = "http://localhost:9090"
}

variable "grafana_admin_user" {
  type        = string
  description = "Grafana admin username"
  default     = "admin"
}

variable "grafana_admin_password" {
  type        = string
  description = "Grafana admin password. Pass through a secret variable in real environments."
  sensitive   = true
  default     = null
}

variable "grafana_allowed_cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed to access Grafana"
  default     = []
}

variable "enable_vault_integration" {
  type        = bool
  description = "Enable a Vault-backed secret lookup for integration testing"
  default     = false
}

variable "vault_address" {
  type        = string
  description = "Vault server address"
  default     = ""
}

variable "vault_token" {
  type        = string
  description = "Vault token for integration testing"
  default     = ""
  sensitive   = true
}

variable "vault_namespace" {
  type        = string
  description = "Optional Vault namespace"
  default     = ""
}

variable "vault_skip_tls_verify" {
  type        = bool
  description = "Skip TLS verification when connecting to Vault"
  default     = false
}

variable "vault_kv_mount" {
  type        = string
  description = "KV v2 mount name in Vault"
  default     = "secret"
}

variable "vault_secret_path" {
  type        = string
  description = "Path to the KV v2 secret to read"
  default     = ""
}

variable "vault_secret_key" {
  type        = string
  description = "Key inside the Vault secret data to read"
  default     = "value"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags applied to resources"
  default     = {}
}
