# EKS Cluster Example

This example shows how to provision an Amazon EKS cluster using the `eks-cluster` platform module.

## What this example is for

- A shared EKS cluster for developer workloads
- A starting point for Backstage self-service provisioning
- A reference implementation for EKS-based platform onboarding
- A landing-zone aware module that can resolve network defaults from AWS SSM
- Managed node groups with environment-appropriate sizing and capacity types
- Built-in IRSA support for workload identity
- Optional AWS Load Balancer Controller IRSA role
- Cluster encryption, logging, and security defaults
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
- Kubernetes version

The example assumes the regional landing zone already provides:

- VPC ID (via SSM parameter `/platform/{region}/{profile}/vpc-id`)
- Private subnet IDs (via SSM parameter `/platform/{region}/{profile}/private-subnet-ids`)

## Environment defaults

- **dev**: 1 node (t3.medium, SPOT), public endpoint, minimal sizing
- **qa**: 1 node (t3.medium, SPOT), private endpoint, moderate sizing
- **prod**: 2 nodes (t3.medium/large, ON_DEMAND), private endpoint, larger headroom

## Outputs

After apply, you can access the cluster using:

```bash
aws eks update-kubeconfig --region <region> --name <cluster_name>
```

The `kubeconfig` output contains the cluster configuration data for programmatic use.
