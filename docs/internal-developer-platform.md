# Internal Developer Platform View

This repository is structured to behave like a platform product in Backstage rather than a loose Terraform collection.

## Product Surface

The Backstage portal exposes three main user journeys:

- discover the platform foundation and reusable Terraform modules in the catalog
- self-service a customer ECS runtime through the scaffolder
- self-service a Jenkins infrastructure definition through the scaffolder

## Product Boundaries

The product currently provides:

- AWS infrastructure modules for Jenkins and ECS runtime delivery
- environment-aware Terraform inputs for `dev`, `qa`, and `prod`
- ownership metadata through Backstage catalog entities
- standards, runbooks, and implementation docs for platform consumers

The product does not yet provide:

- mature golden-path approvals and policy enforcement
- fully production-hardened Backstage authentication and publishing
- automated drift detection and reconciliation

## Backstage Registration

For a local portal running on `http://localhost:7000`, register these entity sources:

- `/catalog-info.yaml`
- `/.backstage/system-and-components.yaml`
- `/.backstage/groups-and-users.yaml`
- `/templates/create-jenkins-ec2-template.yaml`
- `/templates/create-customer-ecs-runtime-template.yaml`
- `/templates/create-standard-service-template.yaml`

The repository already includes these targets in the local Backstage config under [backstage-local-test/app-config.yaml](../backstage-local-test/app-config.yaml) and [backstage/app-config-plugins.yaml](../backstage/app-config-plugins.yaml).

## Recommended Demo Narrative

When showing this repo as a platform-as-product:

1. Open the Backstage catalog and show the platform system plus component ownership.
2. Open the Create page and provision either a Jenkins definition or a customer ECS runtime.
3. Show the generated repo structure, environment tfvars, and platform standards that come with the scaffolded output.
