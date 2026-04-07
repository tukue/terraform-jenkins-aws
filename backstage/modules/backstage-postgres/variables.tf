variable "environment" {
  type        = string
  description = "Environment name"
}

variable "allocated_storage" {
  type        = number
  default     = 100
  description = "Allocated storage in GB"
}

variable "instance_class" {
  type        = string
  default     = "db.t3.medium"
  description = "RDS instance class"
}

variable "db_name" {
  type        = string
  default     = "backstage"
  description = "Database name"
  sensitive   = false
}

variable "user" {
  type        = string
  default     = "backstage_admin"
  description = "Master username"
  sensitive   = true
}

variable "password" {
  type        = string
  description = "Master password (minimum 8 characters)"
  sensitive   = true

  validation {
    condition     = length(var.password) >= 8
    error_message = "Password must be at least 8 characters."
  }
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for DB subnet group"
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security group IDs for RDS"
}

variable "backup_retention_days" {
  type        = number
  default     = 30
  description = "Backup retention period in days"
}

variable "multi_az" {
  type        = bool
  default     = true
  description = "Enable multi-AZ deployment"
}

variable "publicly_accessible" {
  type        = bool
  default     = false
  description = "Enable public accessibility"
}

variable "skip_final_snapshot" {
  type        = bool
  default     = false
  description = "Skip final snapshot when destroying"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags"
}
