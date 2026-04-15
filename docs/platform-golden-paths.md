# Platform Golden Paths

This document defines the preferred consumer journeys for the platform products in this repository.

The goal of a golden path is to make the default way of using the platform obvious, repeatable, and supportable.

## Golden Path Intent

The platform should be consumed through standard paths before any customization is introduced.

In this repository, there are two primary golden paths:

- `Jenkins on AWS`
- `Customer ECS Runtime`

These are the product paths that should be used in demos, reviews, onboarding, and platform evolution work.

## Shared Flow

Both product tracks follow the same high-level consumer model:

1. Understand the product boundary and choose the correct platform path.
2. Start from the documented baseline rather than building from scratch.
3. Use environment-aware configuration for `dev`, `qa`, and `prod`.
4. review the generated or checked-in infrastructure definition
5. apply validation, governance, and support expectations from the shared platform docs
6. treat non-standard customization as exception work

## Golden Path 1: Jenkins on AWS

### When To Use It

Use this path when a team needs:

- a standard Jenkins runtime on AWS
- a reusable baseline for CI/CD infrastructure
- a documented path for environment-aware provisioning

### Preferred Consumer Journey

1. Read [Jenkins on AWS Platform Product](./platform-product-jenkins.md) to understand scope, responsibilities, and maturity level.
2. Read [Getting Started](./getting-started.md) for prerequisites and Terraform basics.
3. Select the target environment using the repo’s `terraform.dev.tfvars`, `terraform.qa.tfvars`, or `terraform.prod.tfvars`.
4. Initialize Terraform with the matching backend config such as `backend-config-dev.hcl`.
5. Run plan and review the infrastructure change as a product baseline, not as one-off infra.
6. Apply the selected environment configuration.
7. Use [DEPLOYMENT-GUIDE.md](../DEPLOYMENT-GUIDE.md) and [Scaling Jenkins Runbook](./runbooks/scaling-jenkins.md) for operational follow-through.

### Expected Outputs

The consumer should end with:

- a provisioned Jenkins baseline on AWS
- environment-aligned Terraform state and variables
- a standard operating starting point for Jenkins infrastructure

### Stay On The Path

The Jenkins golden path stays healthy when:

- the team uses existing Terraform structure and environment files
- changes to shared modules are reviewed as platform changes
- team-specific customization does not silently alter the shared baseline

## Golden Path 2: Customer ECS Runtime

### When To Use It

Use this path when a team needs:

- a repeatable ECS runtime foundation
- a standard multi-environment runtime structure
- a reusable platform path for customer or tenant workloads

### Preferred Consumer Journey

1. Read [Customer ECS Runtime Platform Product](./platform-product-ecs-runtime.md) to understand product boundaries and responsibilities.
2. Review [Multi-Tenant Customer Runtime Design](./multi-tenant-customer-runtime-design.md) and [Multi-Tenant ECS Provisioning Implementation](./multi-tenant-ecs-provisioning-implementation.md).
3. Start from the standard runtime pattern in [platform-examples/customer-ecs-runtime/README.md](../platform-examples/customer-ecs-runtime/README.md) or the matching reusable module in `platform-modules/`.
4. Use the existing environment-specific structure for `dev`, `qa`, and `prod`.
5. Keep workload-specific inputs limited to the documented runtime contract.
6. Validate the runtime configuration before apply.
7. Treat any deviation from the standard runtime structure as exception work.

### Expected Outputs

The consumer should end with:

- a consistent ECS runtime baseline
- a standard environment promotion structure
- a documented runtime foundation that is easier to support and evolve

### Stay On The Path

The ECS golden path stays healthy when:

- teams prefer the reusable runtime structure over bespoke stacks
- environment promotion remains visible and consistent
- runtime-specific customization is kept separate from shared platform logic

## Local Evaluation Path

There is also a local evaluation path for reviewing the platform experience before AWS-backed applies.

Use [Local Platform Quickstart](./local-platform-quickstart.md) when you want to:

- inspect the local platform workflow
- review templates and product assets locally
- validate the repo’s platform story without provisioning AWS resources first

This path supports evaluation, but it is not the primary non-Backstage golden path for infrastructure delivery.

## What Breaks The Golden Path

The platform becomes harder to support when teams:

- bypass the standard modules and environment structure
- mix product-level defaults with one-team custom logic
- treat advisory practices as if they are enforced controls
- make unsupported exceptions without documenting them

## Governance Hooks

The golden paths depend on a small set of cross-cutting rules:

- shared modules should remain reusable and reviewed
- environment-aware configuration should remain the default model
- product docs should stay aligned with actual implementation
- support and governance boundaries should be explicit

Use these docs alongside the product flows:

- [Platform Governance Model](./platform-governance-model.md)
- [Platform Support Model](./platform-support-model.md)
- [Platform Operating Model](./platform-operating-model.md)

## Success Criteria

The golden paths are working when:

- a new reviewer can identify the right product path quickly
- consumers know where to start and what they will get
- the shared baseline remains easier to support than custom deviations
- the repo tells a consistent product story across docs, modules, and examples
