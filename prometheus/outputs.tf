output "workspace_id" {
  description = "Amazon Managed Service for Prometheus workspace ID"
  value       = aws_prometheus_workspace.this.id
}

output "workspace_arn" {
  description = "Amazon Managed Service for Prometheus workspace ARN"
  value       = aws_prometheus_workspace.this.arn
}

output "prometheus_endpoint" {
  description = "Prometheus query endpoint URL"
  value       = aws_prometheus_workspace.this.prometheus_endpoint
}

output "otel_collector_log_group_name" {
  description = "CloudWatch log group name for OpenTelemetry collector logs"
  value       = var.create_otel_log_group ? aws_cloudwatch_log_group.otel_collector[0].name : null
}

output "otel_collector_config" {
  description = "OpenTelemetry Collector metrics pipeline configuration for Jenkins to AMP remote write"
  value       = local.otel_collector_config
}
