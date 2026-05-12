# Platform Templates

This directory contains Backstage Scaffolder templates for the two platform tracks in this repository.

## Templates

### AWS VPC Setup

**File**: `create-vpc-template.yaml`

Provisions a standard AWS VPC with public and private subnets across multiple availability zones, including an optional NAT Gateway and internet connectivity.

### RDS Database

**File**: `create-rds-database-template.yaml`

Provisions a secure, managed RDS database instance (PostgreSQL or MySQL) with platform guardrails, storage configuration, and tagging.

### EC2 Instance

**File**: `create-ec2-instance-template.yaml`

Provisions a standard EC2 instance with platform guardrails, monitoring, and automated tagging.

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

### Secure S3 Bucket

**File**: `create-s3-bucket-template.yaml`

Creates a standalone repository for a tagged, encrypted S3 bucket with public access blocked, object ownership enforced, versioning enabled by default, and lifecycle controls for noncurrent object versions.

Use this when a team needs a standard storage bucket without hand-writing the baseline security controls.

### Security Group

**File**: `create-security-group-template.yaml`

Creates a standalone repository for a tagged AWS security group with explicit ingress and egress rule inputs.

Use this when a team needs reusable network access control without bypassing platform ownership, environment, and cost tags.

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
