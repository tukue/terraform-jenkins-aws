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

output "vault_integration_enabled" {
  description = "Whether Vault integration testing is enabled"
  value       = var.enable_vault_integration
}

output "vault_test_secret_value" {
  description = "Sensitive value read from Vault for integration testing"
  value       = local.vault_test_secret_value
  sensitive   = true
}
