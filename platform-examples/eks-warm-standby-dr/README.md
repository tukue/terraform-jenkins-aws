# EKS Warm-Standby DR Portfolio Reference

This example provisions matching EKS clusters in a primary and standby Region using the existing `eks-cluster` platform module. It demonstrates regional infrastructure symmetry for a warm-standby recovery design.

## Scope

- Two independently provisioned EKS clusters in one AWS account
- One minimal system node group and one minimal application node group per Region
- Private EKS API endpoints, EKS add-ons, OIDC, IRSA, logging, and Load Balancer Controller roles inherited from the shared module
- Outputs needed by a delivery pipeline to identify each cluster

## Deliberate limitations

This is a portfolio reference, not production-grade DR. It does not configure application data replication, Route 53 failover, ECR replication, secrets replication, capacity reservations, or automated failover. Configure ECR replication through the separate `../ecr-replication-dr/` account-baseline example.

## Demonstration

1. Copy `terraform.tfvars.example` to a local `terraform.tfvars` and provide an account ID.
2. Run `terraform init`, `terraform plan`, and `terraform apply` only in a sandbox account.
3. Configure ECR replication and deploy the same immutable image digest to both clusters.
4. Follow [the DR runbook](../../docs/runbooks/portfolio-warm-standby-dr.md) to demonstrate controlled failover.

Destroy both regional stacks after the demonstration to avoid ongoing EKS charges.
