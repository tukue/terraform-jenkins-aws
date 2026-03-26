data "aws_region" "current" {}

resource "aws_prometheus_workspace" "this" {
  alias = "${var.environment}-${var.workspace_alias}"

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-${var.workspace_alias}"
      Environment = var.environment
      Service     = "observability"
      ManagedBy   = "terraform"
    }
  )
}

resource "aws_cloudwatch_log_group" "otel_collector" {
  count = var.create_otel_log_group ? 1 : 0

  name              = "/platform/${var.environment}/otel-collector"
  retention_in_days = var.otel_log_retention_in_days

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-otel-collector-logs"
      Environment = var.environment
      Service     = "observability"
      ManagedBy   = "terraform"
    }
  )
}

locals {
  prometheus_targets_yaml = join(
    "\n",
    [for target in var.jenkins_static_targets : "            - ${target}"]
  )

  otel_collector_config = <<-EOT
    receivers:
      otlp:
        protocols:
          grpc:
            endpoint: 0.0.0.0:4317
          http:
            endpoint: 0.0.0.0:4318
      prometheus:
        config:
          scrape_configs:
            - job_name: jenkins
              scrape_interval: 15s
              static_configs:
                - targets:
${local.prometheus_targets_yaml}

    processors:
      batch: {}
      memory_limiter:
        check_interval: 1s
        limit_mib: 512
      resource:
        attributes:
          - key: service.name
            value: jenkins-platform
            action: upsert
          - key: deployment.environment
            value: ${var.environment}
            action: upsert

    extensions:
      sigv4auth:
        region: ${data.aws_region.current.region}
        service: aps

    exporters:
      prometheusremotewrite:
        endpoint: ${aws_prometheus_workspace.this.prometheus_endpoint}api/v1/remote_write
        auth:
          authenticator: sigv4auth

    service:
      extensions: [sigv4auth]
      pipelines:
        metrics:
          receivers: [prometheus, otlp]
          processors: [memory_limiter, resource, batch]
          exporters: [prometheusremotewrite]
  EOT
}
