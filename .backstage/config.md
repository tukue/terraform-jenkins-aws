# Backstage Platform Configuration

This file contains the Backstage configuration for the terraform-jenkins-aws platform.

## Overview

This project is registered as an Infrastructure component in Backstage and provides platform services for automated Jenkins deployment on AWS.

## Catalog Information

- **Component**: terraform-jenkins-aws
- **Type**: Infrastructure
- **Owner**: Platform Team
- **System**: jenkins-platform
- **Lifecycle**: Production

## Integration Points

### Terraform Module Discovery
This directory contains Terraform modules that are automatically discovered by Backstage:

- `networking/` - VPC and networking infrastructure
- `security-groups/` - Security group definitions
- `jenkins/` - Jenkins EC2 instance
- `load-balancer/` - Application Load Balancer
- `certificate-manager/` - SSL/TLS certificates
- `domain-registration/` - Route 53 DNS

### GitHub Integration
- Repository: https://github.com/tukue/terraform-jenkins-aws
- Main Branch: main
- Catalog File: catalog-info.yaml

### Documentation
- Getting Started: [docs/getting-started.md](../docs/getting-started.md)
- Architecture: [docs/architecture.md](../docs/architecture.md)
- Runbooks: [docs/runbooks/](../docs/runbooks/)

## Configuration Files

### catalog-info.yaml
Defines this component in Backstage catalog.

### Related Files
- `IMPLEMENTATION-BACKLOG.md` - Platform implementation roadmap
- `CONTRIBUTING.md` - Contribution guidelines

## Plugins & Integration

### Required Backstage Plugins
- @backstage/plugin-catalog
- @backstage/plugin-scaffolder
- @backstage/plugin-techdocs
- @backstage/plugin-github
- @backstage/plugin-kubernetes

### AWS Integration Plugins
- @aws-backstage/plugin-aws
- @backstage/plugin-aws-core

### Terraform Plugins
- @spotify/backstage-plugin-terraform

## Linking in Backstage

To link this in Backstage, add the following to your Backstage `app-config.yaml`:

```yaml
catalog:
  providers:
    githubOrg:
      default:
        orgs: ['tukue']
        teams:
          include: ['platform-*']
```

## Component Dependencies

This component depends on:
- AWS Account with VPC support
- Route 53 for DNS
- ACM for SSL certificates
- S3 for Terraform state

## Consumed By

This component provides infrastructure for:
- Jenkins CI/CD Platform
- Platform development and testing
- Jenkins plugin development

## Related Components

- Monitoring System (CloudWatch)
- Security Scanning (Checkov)
- Cost Management (AWS Cost Explorer)
