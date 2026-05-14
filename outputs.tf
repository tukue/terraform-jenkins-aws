output "observability_workspace_id" {
  description = "Managed Prometheus workspace ID (when observability is enabled)"
  value       = var.enable_observability ? module.prometheus[0].workspace_id : null
}

output "observability_prometheus_endpoint" {
  description = "Managed Prometheus endpoint (when observability is enabled)"
  value       = var.enable_observability ? module.prometheus[0].prometheus_endpoint : null
}

output "observability_otel_collector_config" {
  description = "OpenTelemetry Collector config to integrate Jenkins metrics with AMP"
  value       = var.enable_observability ? module.prometheus[0].otel_collector_config : null
}

output "cloudwatch_observability_dashboard_url" {
  description = "CloudWatch dashboard URL for Jenkins observability"
  value       = var.enable_observability ? module.cloudwatch_observability[0].dashboard_url : null
}

output "cloudwatch_cpu_alarm_name" {
  description = "CloudWatch alarm name for Jenkins CPU"
  value       = var.enable_observability ? module.cloudwatch_observability[0].cpu_alarm_name : null
}

output "cloudwatch_status_check_alarm_name" {
  description = "CloudWatch alarm name for Jenkins EC2 status checks"
  value       = var.enable_observability ? module.cloudwatch_observability[0].status_check_alarm_name : null
}

output "grafana_url" {
  description = "Grafana service URL"
  value       = var.enable_grafana_service ? module.grafana[0].grafana_url : null
}

output "jenkins_url" {
  description = "Public Jenkins URL exposed through the ALB"
  value       = module.jenkins_alb_waf.jenkins_url
}

output "jenkins_alb_dns_name" {
  description = "DNS name of the public Jenkins ALB"
  value       = module.jenkins_alb_waf.alb_dns_name
}

output "jenkins_alb_zone_id" {
  description = "Hosted zone ID of the public Jenkins ALB"
  value       = module.jenkins_alb_waf.alb_zone_id
}

output "jenkins_waf_web_acl_arn" {
  description = "WAF Web ACL ARN attached to the Jenkins ALB"
  value       = module.jenkins_alb_waf.waf_web_acl_arn
}

output "vpc_id" {
  description = "Jenkins VPC ID"
  value       = module.networking.vpc_id
}

output "jenkins_instance_id" {
  description = "Jenkins EC2 instance ID"
  value       = module.jenkins.jenkins_ec2_instance_ip
}

output "jenkins_private_ip" {
  description = "Private IP address of the Jenkins EC2 instance"
  value       = module.jenkins.jenkins_private_ip
}

output "jenkins_public_ip" {
  description = "Public IP address of the Jenkins EC2 instance. Null when Jenkins is private."
  value       = module.jenkins.dev_proj_1_ec2_instance_public_ip
}

output "security_group_ids" {
  description = "Security group IDs used by Jenkins and the ALB"
  value = {
    jenkins = module.security_group.sg_ec2_jenkins_port_8080
    alb     = module.security_group.sg_alb_http_https_id
  }
}

output "vault_integration_enabled" {
  description = "Whether Vault integration testing is enabled"
  value       = var.enable_vault_integration
}

output "vault_test_secret_value" {
  description = "Sensitive value read from Vault for integration testing"
  value       = local.vault_test_secret_value
  sensitive   = true
}
