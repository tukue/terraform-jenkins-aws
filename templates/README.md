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

## Template Design Principles

- keep customer input small
- validate account, region, and ownership fields
- prefer sensible defaults
- separate advanced overrides from the standard path
- register generated runtime repos in Backstage

## How Registration Works

The Backstage app loads these template files from `backstage/app-config-plugins.yaml`, so they appear in the Create page.

## Related Docs

- [Backstage README](../backstage/README.md)
- [Jenkins Platform README](../README.md)
- [SaaS E-Commerce ECS Platform Design](../docs/multi-tenant-customer-runtime-design.md)
