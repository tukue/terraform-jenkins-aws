# Multi-Region DR Runbook

This runbook operates the platform's active/passive regional recovery path for stateless Kubernetes applications. It combines matching EKS clusters, ECR cross-Region replication, dual-region delivery, and Route 53 failover.

## Platform prerequisites

1. Apply `platform-examples/ecr-replication-dr/` once from the account-baseline state.
2. Apply `platform-examples/eks-warm-standby-dr/` from the regional-platform state, using production capacity settings and separate Terraform state per Region.
3. Apply `platform-examples/route53-failover-dr/` from a DNS state that is independent of either Region.
4. Configure each application repository with `PLATFORM_AWS_REGION`, `PLATFORM_EKS_CLUSTER_NAME`, and `PLATFORM_ECR_REPOSITORY` for the primary target, plus `PLATFORM_DEPLOYMENT_TARGETS` for the ordered regional target list. The first list item must match the primary target.
5. Grant the GitHub OIDC deployment role ECR push and image-description access in the primary Region, ECR image-description access in the standby Region, and EKS access to both clusters.

Each additional target must reference an ECR repository that receives the primary image through replication. Set a lower `replica_count` for warm standby targets when appropriate.

## Normal delivery

1. A developer pushes to `main`.
2. The platform runs the approved test runner, builds one image, generates an SBOM, and blocks High or Critical Trivy findings.
3. The action pushes the immutable image tag to primary ECR and deploys it to primary EKS.
4. The action waits up to five minutes for ECR replication to expose the exact same image digest in the standby Region.
5. The action deploys that tag to standby EKS and verifies both rollouts.

If replication or the standby rollout fails, the workflow fails with the affected Region and does not report a successful dual-region deployment.

## Failover

1. Confirm the Route 53 primary health check is unhealthy and the standby health check is healthy.
2. Confirm the standby workload is ready and serves the configured health path.
3. Route 53 returns the standby alias after its health-check failure threshold; account for recursive DNS resolver caching during the recovery window.
4. Monitor application errors, latency, workload readiness, ECR image digest, and access logs in the standby Region.
5. Announce the regional incident and record failover start time, DNS recovery time, and application recovery time.

Do not manually edit the Route 53 failover records during an incident unless the health-check decision is known to be wrong. Use an approved emergency change when a forced traffic move is required.

## Failback

1. Restore and verify primary ingress, application readiness, dependencies, and data consistency.
2. Confirm primary Route 53 health checks remain healthy for the agreed observation period.
3. Allow Route 53 to return to the primary alias, then monitor errors and latency.
4. Record the incident evidence and create follow-up work for missed RTO, RPO, or operational steps.

## Application requirements

This platform path protects delivery and regional compute availability. Application teams must still design and test:

- Regional data replication and an explicit RPO.
- Replicated or region-local secret delivery.
- Idempotent startup and request behavior during DNS failover.
- A public, dependency-aware HTTPS health endpoint.
- A certificate valid at both regional load balancers.

Run at least one scheduled recovery exercise per application tier. Treat a passing deployment workflow as a delivery check, not proof that application data can recover.
