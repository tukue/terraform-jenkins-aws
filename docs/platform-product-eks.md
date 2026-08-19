# EKS Cluster Platform Product

This document defines the EKS cluster path as a productized capability in this repository.

## Purpose

`EKS Cluster` provides a repeatable platform path for provisioning shared Kubernetes clusters on AWS EKS. The product is intended to replace one-off cluster setup with a reusable baseline that combines Terraform patterns, environment structure, and documented operating guidance.

## Target Users

The primary users of this product are:

- platform teams building a shared Kubernetes foundation
- engineering teams that need a standard EKS delivery path
- application teams deploying containerized workloads on Kubernetes

## What The Product Provides

The EKS cluster product path currently includes:

- reusable Terraform modules for EKS cluster infrastructure (`platform-modules/eks-cluster/`)
- managed node groups with environment-aware sizing and capacity types
- IAM OIDC provider for IRSA workload identity
- cluster encryption with KMS for Kubernetes secrets
- control plane audit logging to CloudWatch
- cluster add-on management (VPC CNI, CoreDNS, kube-proxy)
- optional AWS Load Balancer Controller IRSA role
- environment-aware inputs for `dev`, `qa`, and `prod`
- example implementations and generated template structure
- baseline documentation for cluster design and operation

## Consumer Inputs

Consumers of the EKS product path provide:

- **Cluster name** - prefix used for naming all EKS resources
- **Environment** - dev, qa, or prod (controls sizing, capacity type, and endpoint access)
- **AWS account and region** - where the cluster is provisioned
- **Kubernetes version** - the EKS cluster version
- **Node group configuration** - instance types, min/max/desired sizing per node group
- **Add-on versions** - optional version overrides for cluster add-ons

The platform resolves:

- VPC and subnet placement from the network profile landing zone (SSM parameters)
- IAM roles and policies for cluster and node groups
- OIDC provider setup for IRSA
- Environment-appropriate defaults for scaling and capacity

## Product Maturity

| Area | Status |
|:---|:---|
| Terraform module | Implemented |
| Example implementation | Implemented |
| Backstage template | Implemented |
| Multi-environment config | Implemented |
| Cluster encryption | Implemented |
| Control plane logging | Implemented |
| IRSA support | Implemented |
| LB Controller integration | Implemented |
| Add-on management | Implemented |
| EKS Access Entries (IAM auth) | Implemented |
| AL2023 default AMI | Implemented |
| Pod Identity Agent add-on | Implemented |
| Upgrade policy (EXTENDED support) | Implemented |
| Karpenter support | Not yet implemented |
| Fargate profiles | Not yet implemented |
| Cluster auto-scaler | Not yet implemented |

## Related Documents

- [Kubernetes Platform Design](./kubernetes-platform-design.md)
- [Platform Golden Paths](./platform-golden-paths.md)
- [Platform Service Tiers](./platform-service-tiers.md)
- [Platform Operating Model](./platform-operating-model.md)
