# Kubernetes Platform Design for `terraform-jenkins-aws`

## Overview

This document defines how to extend the current AWS Jenkins platform into a Kubernetes-based internal developer platform.

The objective is to provide a reusable Kubernetes runtime for application teams while keeping the platform easy to operate, secure, and discoverable through Backstage.

---

## Goals

- Provide Kubernetes infrastructure on AWS
- Support self-service deployment for application teams
- Keep platform operations standardized and repeatable
- Integrate the runtime into Backstage for discovery and documentation
- Preserve the existing Jenkins and AWS foundation where useful

---

## Non-Goals

- Replacing every existing AWS service
- Building a generic cloud platform for every possible workload
- Creating a fully managed multi-cloud abstraction
- Removing Jenkins immediately

The Kubernetes platform should extend the current repo, not rewrite it.

---

## Target Users

- Application developers who need a container runtime
- Platform engineers who own the shared Kubernetes layer
- DevOps engineers who manage deployment and release tooling
- Operations teams that need visibility and control

---

## Recommended Platform Choice

### Primary choice: Amazon EKS

EKS is the best fit for this repository because it aligns with the existing AWS-first architecture.

#### Why EKS fits well

- Uses the current AWS foundation
- Supports managed control plane operations
- Integrates with IAM, VPC, Route 53, and ACM
- Works well with Backstage and Terraform
- Supports a strong ecosystem of add-ons and integrations

### Alternative choice: ECS

ECS may be easier to operate, but it gives less flexibility for platform growth.

Use ECS only if the business wants a simpler container hosting model and does not need Kubernetes features.

---

## Platform Architecture

### 1. Foundation layer

This layer provides shared AWS services:

- VPC
- Public and private subnets
- Routing and NAT
- Security groups
- IAM roles and policies
- Route 53
- ACM certificates
- S3 state backend

### 2. Kubernetes layer

This layer provides the core cluster services:

- EKS control plane
- Managed node groups or Fargate profiles
- Cluster authentication and authorization
- Cluster add-ons
- Ingress controller
- DNS automation
- TLS certificate automation
- Cluster metrics and logs

### 3. Developer experience layer

This layer is what developers use:

- Backstage catalog entries
- Backstage TechDocs
- Self-service templates
- Application namespaces
- Deployable workload templates
- Preview environments

### 4. Operations layer

This layer supports ongoing platform health:

- Monitoring
- Logging
- Alerting
- Policy enforcement
- Cost tracking
- Backup and recovery

---

## Kubernetes Capabilities

### Cluster provisioning

The platform should support:

- Creating a new EKS cluster
- Configuring node groups
- Setting cluster version and upgrade strategy
- Enabling encryption and logging
- Wiring the cluster into the VPC and security model

### Workload onboarding

The platform should help teams:

- Create namespaces
- Apply resource quotas
- Apply network policies
- Add workload identity
- Deploy containerized applications
- Expose services through ingress

### Shared add-ons

Recommended add-ons include:

- AWS Load Balancer Controller
- External DNS
- cert-manager
- metrics-server
- cluster autoscaler or Karpenter
- logging agent
- monitoring stack

---

## Backstage Integration

Backstage should be the front door for the Kubernetes platform.

### Catalog model

Suggested entities:

- `System`: `platform-engineering`
- `Component`: `eks-platform`
- `Component`: `jenkins-platform`
- `Component`: `shared-observability`
- `Resource`: `kubernetes-cluster`
- `Resource`: `namespace-template`
- `API`: platform service API if added later

### Developer flow

1. Developer opens Backstage
2. Developer finds the Kubernetes service
3. Developer selects a template
4. Developer requests a namespace or workload
5. Terraform or an automated workflow provisions it
6. Documentation and runbooks are attached to the service

---

## Terraform Module Design

The Kubernetes platform should be built as reusable Terraform modules.

### Suggested modules

- `eks-cluster`
- `eks-node-group`
- `eks-irsa`
- `eks-addons`
- `k8s-namespace`
- `k8s-ingress`
- `k8s-external-dns`
- `k8s-cert-manager`
- `k8s-observability`

### Module principles

- One module, one responsibility
- Inputs should be explicit and minimal
- Outputs should make composition easy
- Defaults should be secure and opinionated

---

## Security Model

### Identity and access

- Use IAM roles for cluster operations
- Use IRSA for workload permissions
- Separate platform admin access from application access
- Restrict namespace permissions by team

### Network controls

- Private cluster endpoints where possible
- Security groups with least privilege
- Namespace-level isolation
- Network policies for sensitive workloads

### Supply chain controls

- Validate manifests and Terraform in CI
- Scan images before deployment
- Enforce approved base images
- Track who owns each workload

---

## Observability

The platform should expose the health of the cluster and workloads.

### Metrics

- Node health
- Pod health
- Namespace usage
- CPU and memory consumption
- Deployment success rate
- Ingress errors

### Logs

- Cluster control plane logs
- Application logs
- Ingress controller logs
- Audit logs where available

### Dashboards

- Cluster overview
- Namespace usage
- Workload health
- Cost and capacity view

---

## Self-Service Templates

Backstage templates should support common developer needs.

### Starter templates

- Create a namespace
- Deploy a sample application
- Provision an ingress endpoint
- Create a preview environment
- Create a shared config or secret binding

### Platform templates

- Create a new EKS cluster
- Add a new node group
- Provision workload identity
- Create a dashboard entry

---

## Delivery Flow

### Proposed implementation sequence

1. Add an EKS module
2. Add Kubernetes add-ons
3. Add Backstage catalog entities
4. Add a namespace template
5. Add a sample application template
6. Add observability and logging
7. Add governance and policy checks

---

## Operational Model

### Platform team responsibilities

- Keep the cluster healthy
- Upgrade Kubernetes versions
- Maintain add-ons
- Manage access control
- Publish supported templates

### Application team responsibilities

- Deploy workloads into approved namespaces
- Follow standard deployment patterns
- Keep service metadata current
- Use the platform’s supported paths

---

## Success Criteria

The Kubernetes platform is successful if it can show:

- Faster environment provisioning
- Fewer manual cluster setup tasks
- Better standardization across teams
- Clear ownership of workloads
- Visible metrics and operational readiness

---

## Risks

- Kubernetes complexity can grow quickly
- Add-on sprawl can increase maintenance
- Teams may bypass the platform if templates are too rigid
- Poor ownership data can make the catalog less useful

The best mitigation is a small number of strong, well-documented paths.

---

## Recommendation

Build EKS as the primary Kubernetes platform, keep the existing Jenkins and AWS services as supporting components, and use Backstage to expose the platform as a self-service product.
