# Prometheus Observability Module

This module provisions a baseline observability service for the platform using:

- Amazon Managed Service for Prometheus (AMP) workspace
- Optional CloudWatch log group for OpenTelemetry Collector logs
- Generated OpenTelemetry Collector config for Jenkins metric scraping and remote write

## Why This Module

It provides a low-friction, best-practice starting point:
- managed metrics backend (no self-hosted Prometheus server)
- OpenTelemetry-first ingestion
- reusable Terraform interface for platform teams

## Usage

```hcl
module "prometheus" {
  source = "./prometheus"

  environment           = var.environment
  workspace_alias       = "jenkins-platform-observability"
  jenkins_static_targets = ["localhost:8080"]
  tags                  = { Project = "jenkins-platform" }
}
```

## Outputs

- `workspace_id`
- `workspace_arn`
- `prometheus_endpoint`
- `otel_collector_log_group_name`
- `otel_collector_config`

## Integration Pattern

1. Deploy this module.
2. Place `otel_collector_config` content in your collector config file.
3. Run OpenTelemetry Collector on Jenkins host/cluster.
4. Ensure collector IAM role can `aps:RemoteWrite` to this workspace.
