# Portfolio Warm-Standby DR Drill

Use this runbook to demonstrate a controlled, non-production regional recovery scenario for the sample application. It validates infrastructure symmetry, image availability, workload readiness, and a manual traffic-switch decision.

## Scope and boundaries

- Use only sandbox accounts and disposable application data.
- The reference does not automate DNS failover or replicate application data.
- The drill proves a warm standby can host the same image digest; it does not establish a production RTO or RPO.

## Prerequisites

1. Apply `platform-examples/eks-warm-standby-dr/` in a sandbox account.
2. Apply `platform-examples/ecr-replication-dr/` once for the source registry.
3. Push a scanned, immutable sample-application image that matches the ECR replication prefix.
4. Confirm the image digest is available in both Regions:

```bash
aws ecr describe-images --region <primary-region> --repository-name <repository> --image-ids imageTag=<tag>
aws ecr describe-images --region <standby-region> --repository-name <repository> --image-ids imageTag=<tag>
```

5. Deploy the same image digest and Helm values to the primary and standby clusters. Keep the standby replica count minimal for the portfolio demonstration.

## Drill

1. Record the primary endpoint, image digest, and the current standby workload readiness.
2. Simulate primary unavailability by blocking access to the sandbox primary endpoint or scaling the primary application deployment to zero.
3. Confirm the standby deployment is ready:

```bash
kubectl --context <standby-context> get deployment,pods,service --namespace <application>
kubectl --context <standby-context> rollout status deployment/<application> --namespace <application> --timeout=5m
```

4. Manually direct sandbox traffic to the standby endpoint. Record the start and successful-response timestamps.
5. Verify the response, deployed image digest, logs, and application health endpoint.
6. Restore primary traffic, return the primary deployment to its original replica count, and record failback results.

## Evidence to retain

- Terraform plan and apply summaries for both Regions
- Primary and standby cluster names, image digest, and Helm release versions
- ECR replication verification output
- Standby rollout output and health-check response
- Start/end timestamps and any recovery gaps

## Production gaps

Before a production implementation, add a data-replication design, replicated secrets, Route 53 or ARC failover controls, capacity planning, multi-account isolation, alerting, approval workflows, and scheduled recovery tests.
