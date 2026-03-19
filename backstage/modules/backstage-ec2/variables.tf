variable "environment" {
  type        = string
  description = "Environment name"
}

variable "instance_type" {
  type        = string
  default     = "t3.large"
  description = "EC2 instance type"
}

variable "root_volume_size" {
  type        = number
  default     = 100
  description = "Root volume size in GB"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for instance placement"
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security group IDs"
}

variable "iam_instance_profile" {
  type        = string
  description = "IAM instance profile name"
}

variable "key_name" {
  type        = string
  description = "SSH key pair name"
  default     = ""
}

# Database variables
variable "db_host" {
  type        = string
  description = "RDS database host"
  sensitive   = true
}

variable "db_port" {
  type        = number
  description = "RDS database port"
  default     = 5432
}

variable "db_name" {
  type        = string
  description = "Database name"
}

variable "db_user" {
  type        = string
  description = "Database username"
  sensitive   = true
}

variable "db_password" {
  type        = string
  description = "Database password"
  sensitive   = true
}

# GitHub integration
variable "github_client_id" {
  type        = string
  description = "GitHub OAuth2 Client ID"
  sensitive   = true
}

variable "github_client_secret" {
  type        = string
  description = "GitHub OAuth2 Client Secret"
  sensitive   = true
}

variable "github_token" {
  type        = string
  description = "GitHub Personal Access Token"
  sensitive   = true
}

variable "backstage_version" {
  type        = string
  default     = "latest"
  description = "Backstage Docker image tag"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags"
}
