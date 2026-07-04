# Jenkins Platform Module

Composable Jenkins platform stack used by the explicit `live/*` environment roots.

The module creates:

- VPC, subnets, routing, NAT, and VPC flow logs
- Jenkins EC2 instance in a private subnet
- ALB and optional WAF public entry point
- Optional managed Prometheus, CloudWatch dashboard/alarms, and Grafana service
- Optional Vault lookup for integration testing

Keep environment-specific backend configuration and provider credentials in the `live/<env>` roots. This module should stay backend-free so it can be reused safely across dev, QA, and prod.
