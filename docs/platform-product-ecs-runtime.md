# Customer ECS Runtime Platform Product

This document defines the customer ECS runtime path as a productized capability in this repository.

## Purpose

`Customer ECS Runtime` provides a repeatable platform path for provisioning customer-facing or tenant-oriented application runtimes on AWS ECS.

The product is intended to replace one-off runtime setup with a reusable baseline that combines Terraform patterns, environment structure, and documented operating guidance.

## Target Users

The primary users of this product are:

- platform teams building reusable runtime foundations
- engineering teams that need a standard ECS delivery path
- consulting stakeholders evaluating platform-product design

## What The Product Provides

The ECS runtime product path currently includes:

- reusable Terraform modules for customer ECS runtime infrastructure
- environment-aware inputs for `dev`, `qa`, and `prod`
- example implementations and generated template structure
- baseline documentation for runtime design and implementation status
- a path that can be presented as a repeatable golden-path runtime capability

## Consumer Inputs

Consumers of this product are expected to provide:

- workload-specific runtime configuration
- environment selection
- customer or tenant-specific values where required
- account, region, networking, and secret inputs needed by the Terraform baseline

## Consumer Outputs

A successful use of this product path should result in:

- a consistent ECS runtime structure for the selected environment
- standardized Terraform inputs and outputs
- a documented baseline for deployment and operations
- a clearer starting point for promotion across environments

## Supported Use Cases

Use this product path when a team needs:

- a repeatable ECS runtime foundation
- standardized environment configuration
- a reusable customer-runtime pattern instead of bespoke Terraform delivery

## Out of Scope

This product path does not currently promise:

- a full enterprise multi-account orchestration model
- a mature service mesh or advanced network policy platform
- complete tracing and full observability coverage
- fully automated drift reconciliation
- support for every workload type beyond the current ECS-oriented baseline

## Consumer Responsibilities

Consumers are responsible for:

- providing application-specific runtime configuration
- handling exceptions beyond the standard platform path
- operating the application layer that runs on the runtime
- managing approvals and organizational controls not enforced in the shared baseline

## Platform Team Responsibilities

The shared platform layer is responsible for:

- maintaining the reusable runtime pattern
- documenting supported inputs, defaults, and limitations
- keeping the environment model coherent across examples and modules
- evolving the runtime baseline toward stronger guardrails and operability

## Default Guardrails

The current baseline assumes:

- reusable modules and examples are preferred over bespoke stacks
- environment-specific tfvars define the expected promotion path
- tagging, security, and runtime defaults are part of the platform contract
- the product is strongest when consumers stay on the documented path

## Maturity Position

This product should be presented as:

- a credible ECS-focused platform product path
- a reusable runtime foundation for platform engineering work
- a practical reference for standardization and enablement

It should not be presented as:

- a fully production-hardened internal developer platform runtime
- a complete multi-runtime application platform
- a finished enterprise governance model

## Related Docs

- [Platform Operating Model](./platform-operating-model.md)
- [Platform-as-a-Product Implementation Status](./platform-as-product-implementation-status.md)
- [Multi-Tenant Customer Runtime Design](./multi-tenant-customer-runtime-design.md)
- [Multi-Tenant ECS Provisioning Implementation](./multi-tenant-ecs-provisioning-implementation.md)
