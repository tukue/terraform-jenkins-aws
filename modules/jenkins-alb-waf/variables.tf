variable "name_prefix" {
  description = "Name prefix for Jenkins ALB and WAF resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the Jenkins ALB target group is created"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the internet-facing ALB"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID attached to the ALB"
  type        = string
}

variable "jenkins_instance_id" {
  description = "Jenkins EC2 instance ID registered as an ALB target"
  type        = string
}

variable "jenkins_port" {
  description = "Jenkins listener port on the EC2 instance"
  type        = number
  default     = 8080
}

variable "certificate_arn" {
  description = "ACM certificate ARN. When set, HTTPS is enabled and HTTP redirects to HTTPS."
  type        = string
  default     = ""
}

variable "enable_waf" {
  description = "Attach an AWS WAFv2 Web ACL to the Jenkins ALB"
  type        = bool
  default     = true
}

variable "waf_rate_limit" {
  description = "Maximum requests per 5-minute period from a single IP before WAF blocks it"
  type        = number
  default     = 2000
}

variable "tags" {
  description = "Tags applied to ALB and WAF resources"
  type        = map(string)
  default     = {}
}
