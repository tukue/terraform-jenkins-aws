# Platform Product Design: Kubernetes and Developer Self-Service

## Purpose

This document describes how to evolve the current `terraform-jenkins-aws` repository from a Jenkins-on-AWS infrastructure project into a platform product that can provide:

- Kubernetes infrastructure for application teams
- Other business-required developer services such as databases, messaging, storage, CI/CD runners, and preview environments
- A Backstage-powered self-service experience with documentation, templates, and governance

The goal is to make the repository useful as a real internal developer platform and also strong as a portfolio project for platform engineering interviews.

---

## Current State

The repository already contains several platform foundations:

- Terraform modules for AWS infrastructure
- A Backstage deployment area
- `catalog-info.yaml` for catalog registration
- Documentation, standards, and runbooks
- A reusable module structure for infrastructure components
- Observability assets for Prometheus and Grafana

This means the repo is already positioned as a platform foundation. The next step is to expand it from a single-purpose Jenkins platform into a broader developer platform.

---

## Product Vision

The platform should become the place where a developer can go to request and operate common infrastructure and runtime services without needing deep AWS knowledge.

### Product promise

- Provision environments through templates
- Use standardized, secure defaults
- Discover services and documentation in Backstage
- Reduce manual platform work
- Support multiple service types without rebuilding the platform each time

---

## Target Users

- Application developers who need a runtime platform
- Platform engineers who own guardrails, templates, and shared services
- DevOps engineers who manage CI/CD and release workflows
- Team leads or product teams who need predictable delivery and visibility

---

## What The Platform Should Provide

### 1. Kubernetes infrastructure

Provide a managed Kubernetes layer on AWS, most likely with EKS, so teams can deploy containerized workloads using a standard platform.

Capabilities should include:

- EKS cluster provisioning
- Managed node groups or Fargate profiles
- Cluster networking and security groups
- Ingress and load balancing
- DNS and TLS integration
- Secret and identity integration
- Logging, metrics, and alerting
- Namespace-based isolation for teams or applications

### 2. Other developer business services

Not every team needs Kubernetes immediately. The platform should also offer other services that developers commonly request:

- PostgreSQL or MySQL database provisioning
- S3 buckets for application storage
- Redis or cache services
- Message queues such as SQS or RabbitMQ
- CI/CD runners or build agents
- Preview or ephemeral environments
- Shared observability dashboards
- Domain and certificate provisioning

This lets the platform serve different business needs instead of forcing every use case into one runtime model.

---

## Recommended Platform Direction

### Primary direction: AWS-managed Kubernetes platform

Because this repo is already AWS-based, the cleanest upgrade path is:

- Keep Terraform as the infrastructure engine
- Add an EKS module set
- Use Backstage as the developer portal
- Use templates for self-service provisioning
- Keep Jenkins as an existing workload or migration bridge

This approach preserves what already works while opening the door to modern application workloads.

### Secondary direction: service catalog for multiple business needs

The platform should not become “just Kubernetes.”

Instead, it should expose a catalog of platform capabilities:

- `k8s-application-runtime`
- `database-provisioning`
- `preview-environment`
- `build-runner`
- `object-storage`
- `domain-and-certificates`

That structure makes the repo easier to evolve because new services can be added without changing the whole platform shape.

---

## Proposed Architecture

### Layer 1: Platform foundation

This layer contains the AWS core needed by all services:

- VPC
- Subnets
- Routing
- Security groups
- IAM roles and policies
- DNS
- Certificate management
- S3 backend and state management

### Layer 2: Runtime platform

This layer provides shared workloads and service hosting:

- EKS cluster
- Jenkins or CI runners
- Ingress controller
- Observability stack
- Secret management
- Shared addons such as external DNS, cert-manager, and metrics server

### Layer 3: Self-service products

This layer is what developers consume:

- Application templates
- Namespace templates
- Database templates
- Preview environment templates
- Storage templates
- Internal service templates

### Layer 4: Experience layer

This layer is the front door:

- Backstage catalog
- TechDocs
- Scaffolder templates
- Service ownership metadata
- Runbooks
- Golden path documentation

---

## Kubernetes Upgrade Design

### Option A: Add EKS to the existing AWS platform

This is the most realistic and reusable option.

#### What gets added

- `eks/` Terraform module
- Node group definitions
- IAM roles for cluster and workload access
- OIDC provider for IRSA
- Cluster add-ons
- Ingress controller
- External DNS
- Cert-manager
- Metrics and logging pipeline

#### Why this is the best fit

- Aligns with the current AWS stack
- Fits container-based workloads
- Supports modern delivery practices
- Creates a reusable foundation for multiple teams

### Option B: Use ECS instead of Kubernetes

This is a lighter operational option if the business wants simpler container hosting.

#### When to choose it

- Small team
- Lower operational complexity
- No strong need for Kubernetes APIs or portability

#### Tradeoff

- Easier to run
- Less ecosystem flexibility than Kubernetes

### Recommendation

Choose EKS as the main platform path, while keeping ECS or direct AWS services available for lighter use cases.

---

## Business Service Design

The platform should support more than infrastructure provisioning. It should support requests that map to actual business needs.

### Example service catalog entries

- `eks-cluster`
- `app-namespace`
- `postgres-database`
- `redis-cache`
- `s3-storage`
- `preview-env`
- `jenkins-runner`
- `grafana-dashboard`

Each service should have:

- Clear owner
- Lifecycle state
- Documentation link
- Runbook link
- Template or provisioning source
- Dependencies

---

## Self-Service Flow

The ideal developer journey should look like this:

1. Developer opens Backstage
2. Developer searches the catalog
3. Developer selects a template
4. Developer enters a few parameters
5. Platform creates the resource through Terraform or a workflow
6. The resource appears in the catalog
7. Metrics, docs, and runbooks are attached automatically

This is the core of platform-as-a-product: low-friction request, high-consistency delivery.

---

## Backstage Integration Plan

Backstage should become the user interface for the platform.

### Required Backstage capabilities

- Catalog entities for each platform component
- TechDocs for usage and operations
- Scaffolder templates for self-service actions
- Ownership metadata for platform and application teams
- Links to observability and CI/CD tools

### Suggested catalog model

- `System`: `platform-engineering`
- `Component`: `terraform-jenkins-aws`
- `Component`: `eks-platform`
- `Component`: `shared-observability`
- `Resource`: `state-bucket`
- `Resource`: `cluster-database`
- `API`: platform service APIs if exposed later

---

## Terraform Module Strategy

The repo should evolve into a layered module catalog.

### Keep the current modules

- networking
- security groups
- load balancer
- certificate manager
- domain registration
- Jenkins
- Grafana
- Prometheus

### Add new modules

- EKS cluster
- EKS node groups
- IRSA and IAM bindings
- Namespace provisioning
- Ingress controller
- External DNS
- cert-manager
- database provisioning
- preview environment support

### Design principle

Each module should represent one platform capability, not one application.

That makes reuse easier and prevents the repo from turning into a pile of one-off stacks.

---

## Governance And Safety

If the platform is going to be reusable by developers, it needs guardrails.

### Required controls

- Standard naming
- Mandatory tags
- Least-privilege IAM
- Environment separation
- Policy checks in CI
- Drift detection
- Security scanning
- Approval for production changes

### Recommended tooling

- Terraform validation
- Static analysis and linting
- Policy-as-code
- Backstage template restrictions
- Secrets management

---

## Operating Model

### Platform team responsibilities

- Own the templates
- Maintain the Terraform modules
- Keep Backstage catalog data accurate
- Provide runbooks and support
- Add new services based on demand

### Developer responsibilities

- Request services through templates
- Use the supported patterns
- Keep service metadata updated
- Follow documented standards

---

## Phased Implementation

### Phase 1: Foundation

- Clean up product positioning
- Strengthen Backstage catalog entries
- Define platform systems and ownership
- Standardize docs and runbooks

### Phase 2: Kubernetes platform

- Add EKS module
- Add ingress and DNS automation
- Add cluster observability
- Publish a Kubernetes service template

### Phase 3: Business service catalog

- Add database template
- Add storage template
- Add preview environment template
- Add runner template

### Phase 4: Product maturity

- Add dashboards and KPIs
- Add policy enforcement
- Add cost visibility
- Add service ownership reporting

---

## Success Metrics

The platform is succeeding if it can show measurable improvement.

- Time to provision a new environment
- Time to onboard a new developer team
- Number of manual support requests reduced
- Percentage of services created through templates
- Time to recover from common incidents
- Cost visibility per environment or service

---

## Risks

- Kubernetes can add operational complexity
- Too many templates can become hard to maintain
- Backstage can become a documentation graveyard if ownership is unclear
- A platform that is not opinionated enough will confuse users
- A platform that is too opinionated will block adoption

The right balance is to offer strong defaults with a small number of well-supported paths.

---

## Final Recommendation

Upgrade the repository in this order:

1. Make Backstage the front door
2. Add EKS as the primary runtime platform
3. Keep supporting Jenkins as a workload or transition path
4. Expose developer-requested services as cataloged products
5. Treat templates, docs, and runbooks as the product surface

That gives you a platform that can grow from one infrastructure project into a reusable internal developer platform.
