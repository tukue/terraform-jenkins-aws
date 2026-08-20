output "application_dns_name" {
  value       = var.record_name
  description = "Stable DNS name that routes to the healthy primary or standby endpoint"
}

output "health_check_ids" {
  value       = { for region_role, check in aws_route53_health_check.regional : region_role => check.id }
  description = "Route 53 health checks used by the failover records"
}
