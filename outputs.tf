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

output "grafana_url" {
  description = "Grafana service URL"
  value       = var.enable_grafana_service ? module.grafana[0].grafana_url : null
}
