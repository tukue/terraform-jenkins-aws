# Route 53 Regional Failover Baseline

This account-level baseline creates one stable application DNS name with Route 53 active/passive failover between two regional load balancers. It is intended for applications deployed by the platform's optional dual-region delivery path.

## Prerequisites

- A public Route 53 hosted zone.
- HTTPS-capable primary and standby application load balancers, each serving the same health endpoint.
- Dedicated regional DNS names, such as `primary.api.example.com` and `standby.api.example.com`, covered by the regional application certificate.
- EKS clusters and ECR replication provisioned through the existing `../eks-warm-standby-dr/` and `../ecr-replication-dr/` baselines.
- A certificate valid for `record_name` on both regional endpoints.

## Apply

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and provide the hosted zone and load balancer DNS details.
2. Run `terraform init`, `terraform plan`, and `terraform apply` from a centrally owned DNS Terraform state.
3. Configure the platform delivery variables for both regional clusters and registries.
4. Validate health checks and execute the recovery exercise in [the production DR runbook](../../docs/runbooks/multi-region-dr.md).

## Operating model

Route 53 creates the two regional aliases and checks each regional hostname over HTTPS. It answers the primary failover alias while the primary health check succeeds; after the configured failure threshold, it answers the standby alias. DNS caching means client recovery time includes resolver caching; this is not an instant traffic switch. Keep this state independent from application and regional EKS Terraform states so a regional failure does not block DNS recovery.
