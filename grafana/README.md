# Grafana Service Module

This module provisions a self-hosted Grafana service on AWS EC2 so the platform can visualize metrics as a reusable service.

## Why This Module

It gives the platform a dedicated visualization layer while staying portable and easy to explain:
- open source Grafana
- Terraform-managed EC2 runtime
- configurable Prometheus datasource
- easy to pair with the local Docker observability stack

## Usage

```hcl
module "grafana" {
  source = "./grafana"

  environment     = var.environment
  ami_id          = var.ec2_ami_id
  subnet_id       = tolist(module.networking.dev_proj_1_public_subnets)[0]
  vpc_id          = module.networking.dev_proj_1_vpc_id
  allowed_cidrs   = ["0.0.0.0/0"]
  prometheus_url  = "http://your-prometheus-endpoint:9090"
  admin_user      = "admin"
  admin_password  = var.grafana_admin_password
  tags            = var.tags
}
```

## Notes

- Restrict `allowed_cidrs` in production.
- Point `prometheus_url` at your metrics backend.
- Use a strong admin password and store it as a secret in real deployments.
