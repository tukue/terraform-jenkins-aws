variable "lb_target_group_name" {
  description = "Name of the target group"
  type        = string
}

variable "lb_target_group_port" {
  description = "Port on which targets receive traffic"
  type        = number
  default     = 443  # Default to HTTPS port
}

variable "lb_target_group_protocol" {
  description = "Protocol to use for routing traffic to the targets"
  type        = string
  default     = "HTTPS"  # Default to HTTPS protocol
}

variable "vpc_id" {
  description = "ID of the VPC where the target group will be created"
  type        = string
}

variable "ec2_instance_id" {
  description = "ID of the EC2 instance to attach to the target group"
  type        = string
}

variable "environment" {
  description = "Environment for the resources (e.g., dev, qa, prod)"
  type        = string
  default     = "dev"  # Default to dev if not specified
}

variable "health_check_protocol" {
  description = "Protocol to use for health checks"
  type        = string
  default     = "HTTPS"  # Default to HTTPS for health checks
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate to use for HTTPS"
  type        = string
  default     = "dummy-arn"  # Default placeholder value
}

variable "load_balancer_arn" {
  description = "ARN of the load balancer"
  type        = string
  default     = ""  # Default empty value
}