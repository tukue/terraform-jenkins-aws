# EKS Cluster Example

This example shows how to provision an Amazon EKS cluster using the `eks-cluster` platform module with AWS best practices.

## What this example is for

- A shared EKS cluster for developer workloads
- A starting point for Backstage self-service provisioning
- A reference implementation for EKS-based platform onboarding
- A landing-zone aware module that can resolve network defaults from AWS SSM
- Managed node groups with environment-appropriate sizing, capacity types, and node roles
- Built-in IRSA support for workload identity
- Optional AWS Load Balancer Controller IRSA role
- Cluster encryption, logging, and security defaults
- EKS access entries for modern IAM authentication (replaces aws-auth ConfigMap)
- AL2023 (Amazon Linux 2023) as the default node AMI
- EKS Pod Identity Agent add-on for simplified pod IAM
- Environment-specific Terraform files for `dev`, `qa`, and `prod`

## Folder layout

- `provider.tf` - AWS provider configuration
- `main.tf` - Calls the shared EKS cluster module
- `variables.tf` - Input variables
- `outputs.tf` - Useful cluster outputs including kubeconfig
- `terraform.*.tfvars` - Environment-specific Terraform variables
- `terraform.tfvars.example` - Example values including region and account

## How to use

1. Copy this example into a platform-specific folder.
2. Update the values for your account and environment.
3. Run `terraform init` to initialize the providers.
4. Run `terraform plan` to review the infrastructure change.
5. Run `terraform apply` to provision the cluster.

## Recommended inputs

- AWS region selected in Backstage
- AWS account ID selected in Backstage
- Cluster name prefix
- Kubernetes version (minimum 1.31 recommended)
- Access entries for IAM principals (replaces aws-auth ConfigMap)

The example assumes the regional landing zone already provides:

- VPC ID (via SSM parameter `/platform/{region}/{profile}/vpc-id`)
- Private subnet IDs (via SSM parameter `/platform/{region}/{profile}/private-subnet-ids`)

## Best practices applied

### Security
- **EKS Access Entries**: Modern IAM authentication via `API_AND_CONFIG_MAP` mode, replacing manual aws-auth ConfigMap edits
- **KMS encryption**: Kubernetes secrets encrypted at rest with customer-managed KMS key with automatic rotation
- **Private endpoint**: Cluster API endpoint is private in qa/prod environments
- **Security groups**: Least-privilege ingress rules for cluster API communication
- **IMDSv2**: Enforced on all node group instances

### Node groups
- **AL2023**: Amazon Linux 2023 as the default AMI for all node groups
- **Node role separation**: `system` node group for critical add-ons (with taints in prod), `application` node group for workloads
- **Spot instances**: Used in dev/qa for cost optimization; ON_DEMAND in prod
- **Environment-aware sizing**: Larger instance types and node counts in prod

### Operational excellence
- **Control plane logging**: All log types enabled (api, audit, authenticator, controllerManager, scheduler)
- **CloudWatch retention**: 90 days for prod, 30 days for dev/qa
- **Extended support**: Enabled for prod clusters (optional)
- **OIDC provider**: Automatically created for IRSA workload identity
- **AWS Load Balancer Controller**: Pre-configured IRSA role for ingress/ALB management

### Cluster add-ons
- **VPC CNI**: Latest version for pod networking
- **CoreDNS**: Latest version for service discovery
- **kube-proxy**: Latest version for service routing
- **Pod Identity Agent**: Enabled for EKS Pod Identity associations

## Environment defaults

- **dev**: 2 node groups (system + application), SPOT instances, public endpoint restricted to trusted CIDRs
- **qa**: 2 node groups, SPOT instances, private endpoint
- **prod**: 2 node groups with system taints, ON_DEMAND instances, private endpoint, extended upgrade support

## Access management

This example uses EKS Access Entries instead of the legacy aws-auth ConfigMap:

```hcl
access_entries = {
  platform-admin = {
    principal_arn     = "arn:aws:iam::123456789012:role/Admin"
    kubernetes_groups = ["system:masters"]
  }
}

access_policy_associations = {
  admin-cluster = {
    principal_arn     = "arn:aws:iam::123456789012:role/Admin"
    policy_arn        = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
    access_scope_type = "cluster"
  }
}
```

## Outputs

After apply, you can access the cluster using:

```bash
aws eks update-kubeconfig --region <region> --name <cluster_name>
```

The `kubeconfig` output contains the cluster configuration data for programmatic use.
