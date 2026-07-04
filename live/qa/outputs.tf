output "jenkins_url" {
  description = "Public Jenkins URL exposed through the ALB"
  value       = module.jenkins_platform.jenkins_url
}

output "jenkins_alb_dns_name" {
  description = "DNS name of the public Jenkins ALB"
  value       = module.jenkins_platform.jenkins_alb_dns_name
}

output "vpc_id" {
  description = "Jenkins VPC ID"
  value       = module.jenkins_platform.vpc_id
}

output "jenkins_instance_id" {
  description = "Jenkins EC2 instance ID"
  value       = module.jenkins_platform.jenkins_instance_id
}

output "cloudwatch_observability_dashboard_url" {
  description = "CloudWatch dashboard URL for Jenkins observability"
  value       = module.jenkins_platform.cloudwatch_observability_dashboard_url
}
