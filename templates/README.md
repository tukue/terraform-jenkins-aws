# Platform Templates

This directory contains Backstage Scaffolder templates for the two platform tracks in this repository.

## Templates

### Jenkins EC2 Instance

**File**: `create-jenkins-ec2-template.yaml`

Creates a Jenkins EC2 environment with networking, load balancing, TLS, and monitoring.

Use this when you need a standardized Jenkins runtime for delivery workflows.

### Customer ECS Runtime

**File**: `create-customer-ecs-runtime-template.yaml`

Creates a customer-specific ECS runtime for a SaaS e-commerce application.

Use this when the customer selects an AWS account and AWS region, and the platform handles the rest through defaults and landing-zone lookups.

The generated runtime repository includes a DevSecOps checklist so the controls stay visible during onboarding.
It also includes a GitHub Actions workflow that provisions the runtime across `dev`, `qa`, and `prod`, plus a separate workflow that builds the application image, scans it for HIGH and CRITICAL vulnerabilities, and deploys it to the selected environment only when the scan passes.
The provisioning workflow treats `terraform fmt -check`, `terraform validate`, and TFLint as the baseline policy layer before any security scan runs.
The ECS module also provisions a dedicated ECR repository for the approved image.
If the application source repository is private, add a `SOURCE_REPO_TOKEN` secret in the generated runtime repo for checkout access.

## Template Design Principles

- keep customer input small
- validate account, region, and ownership fields
- prefer sensible defaults
- separate advanced overrides from the standard path
- register generated runtime repos in Backstage

## ECS Runtime Inputs

The customer ECS runtime template collects two groups of information:

- platform placement: AWS account, AWS region, tenant details
- image delivery: source repo, deploy role ARN, Dockerfile path, build context, image tag, and target environment

## How Registration Works

The Backstage app loads these template files from `backstage/app-config-plugins.yaml`, so they appear in the Create page.

## Related Docs

- [Backstage README](../backstage/README.md)
- [Jenkins Platform README](../README.md)
- [SaaS E-Commerce ECS Platform Design](../docs/multi-tenant-customer-runtime-design.md)
