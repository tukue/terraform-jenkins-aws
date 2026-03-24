# Terraform Jenkins AWS

This repository is a platform engineering showcase with two product tracks:

- Jenkins platform on AWS for standardized CI/CD and legacy delivery workflows
- ECS customer runtime platform for SaaS onboarding and containerized application delivery

Both tracks use Terraform, Backstage, reusable modules, and operational standards.

## Platform Story

The repo demonstrates how to build a platform as a product, not just as infrastructure:

- self-service templates
- reusable Terraform modules
- clear ownership and guardrails
- docs and runbooks
- observability and supportability

## Track 1: Jenkins Platform

Use this track when a team needs a standardized Jenkins runtime on AWS.

Key capabilities:

- Jenkins on EC2
- S3 state backend
- VPC, networking, and security groups
- ALB and Route 53 integration
- ACM certificate support
- Ansible-based post-provisioning
- Environment-specific tfvars and backend configs for dev, qa, and prod delivery
- GitHub Actions delivery workflow with environment-gated apply steps

## Track 2: ECS Customer Runtime Platform

Use this track when a SaaS application needs customer-specific ECS runtimes.

Key capabilities:

- Backstage self-service provisioning
- customer-selected AWS account and region
- landing-zone aware network resolution
- ECR repository with scan-before-push workflow
- ECS Fargate service and ALB
- AWS WAF protection and managed security defaults
- built-in ECS autoscaling
- container image deployment hooks

## Repository Layout

- `jenkins/` - Jenkins runtime components
- `networking/` - VPC and network foundations
- `security-groups/` - shared network access controls
- `load-balancer/` and `load-balancer-target-group/` - ALB resources
- `domain-registration/` and `hosted-zone/` - Route 53 and DNS
- `certificate-manager/` - ACM certificate resources
- `s3.tf` - Terraform state backend resources
- `backstage/` - Backstage deployment and local compose setup
- `platform-modules/` - reusable platform modules
- `platform-examples/` - example stacks
- `templates/` - Backstage scaffolder templates
- `docs/` - platform design and implementation docs

## Intended Audience

- junior to mid-level engineers building a platform portfolio
- hiring managers and interviewers evaluating platform design
- teams looking for Backstage + Terraform reference patterns

## Getting Started

1. Review the Jenkins track or the ECS track.
2. Open the matching docs in `docs/`.
3. Run the relevant Terraform stack or Backstage template.
4. Adapt the platform module for your own environment.

## Documentation Entry Points

- [SaaS E-Commerce ECS Platform Design](docs/multi-tenant-customer-runtime-design.md)
- [Multi-Tenant ECS Provisioning Implementation](docs/multi-tenant-ecs-provisioning-implementation.md)
- [Backstage Deployment Guide](backstage/README.md)
- [Platform Templates](templates/README.md)

## Contribution Notes

This is a showcase repository, so the main goal is clarity, reusability, and product thinking.

For contribution expectations, see [CONTRIBUTING.md](CONTRIBUTING.md).
