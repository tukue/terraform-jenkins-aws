output "jenkins_url" {
  value       = module.jenkins_infrastructure.jenkins_url
  description = "Jenkins portal URL"
}

output "jenkins_access_info" {
  value = {
    url             = module.jenkins_infrastructure.jenkins_url
    instance_id     = module.jenkins_infrastructure.jenkins_instance_id
    instance_ip     = module.jenkins_infrastructure.jenkins_private_ip
    alb_dns_name    = module.jenkins_infrastructure.jenkins_alb_dns_name
    waf_web_acl_arn = module.jenkins_infrastructure.jenkins_waf_web_acl_arn
    security_groups = module.jenkins_infrastructure.security_group_ids
    vpc_id          = module.jenkins_infrastructure.vpc_id
  }
  description = "Complete Jenkins access information"
}

output "infrastructure_summary" {
  value = {
    environment        = var.environment
    project            = var.project_name
    instance_type      = local.instance_type
    vpc_cidr           = var.vpc_cidr
    monitoring_enabled = var.enable_monitoring
    ansible_enabled    = var.ansible_enabled
  }
  description = "Infrastructure summary"
}

output "vpc_id" {
  value       = module.jenkins_infrastructure.vpc_id
  description = "VPC ID"
}

output "jenkins_instance_id" {
  value       = module.jenkins_infrastructure.jenkins_instance_id
  description = "EC2 Instance ID"
}

output "jenkins_public_ip" {
  value       = module.jenkins_infrastructure.jenkins_public_ip
  description = "Jenkins instance public IP. Null when Jenkins is private."
}

output "jenkins_private_ip" {
  value       = module.jenkins_infrastructure.jenkins_private_ip
  description = "Jenkins instance private IP"
}

output "jenkins_alb_dns_name" {
  value       = module.jenkins_infrastructure.jenkins_alb_dns_name
  description = "Jenkins ALB DNS name"
}

output "jenkins_waf_web_acl_arn" {
  value       = module.jenkins_infrastructure.jenkins_waf_web_acl_arn
  description = "Jenkins WAF Web ACL ARN"
}

output "security_group_ids" {
  value       = module.jenkins_infrastructure.security_group_ids
  description = "Security group IDs"
}

output "monitoring_dashboard_url" {
  value       = var.enable_monitoring ? "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:" : null
  description = "CloudWatch monitoring dashboard URL"
}
