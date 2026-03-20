variable "environment" {
  description = "Deployment environment name (dev, qa, prod)"
  type        = string
}

variable "workspace_alias" {
  description = "Alias used for the Amazon Managed Service for Prometheus workspace"
  type        = string
  default     = "jenkins-platform-observability"
}

variable "jenkins_static_targets" {
  description = "Static Prometheus scrape targets for Jenkins and related services"
  type        = list(string)
  default     = ["localhost:8080"]
}

variable "create_otel_log_group" {
  description = "Whether to create a CloudWatch log group for OpenTelemetry collector logs"
  type        = bool
  default     = true
}

variable "otel_log_retention_in_days" {
  description = "Retention period for OpenTelemetry collector logs"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to observability resources"
  type        = map(string)
  default     = {}
}
