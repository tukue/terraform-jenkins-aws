variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "instance_id" {
  description = "EC2 instance ID to monitor"
  type        = string
}

variable "instance_name" {
  description = "Human-friendly instance name used in dashboard text"
  type        = string
  default     = "Jenkins"
}

variable "instance_public_ip" {
  description = "Public IP address shown in the dashboard"
  type        = string
  default     = ""
}

variable "cpu_alarm_threshold" {
  description = "CPU utilization threshold for the high CPU alarm"
  type        = number
  default     = 80
}

variable "status_check_threshold" {
  description = "Threshold for the EC2 instance status check alarm"
  type        = number
  default     = 0
}

variable "tags" {
  description = "Tags applied to observability resources"
  type        = map(string)
  default     = {}
}
