# Platform Best Practices

This document defines the preferred working style for the platform product paths in this repository.

It is not a generic Terraform checklist. It is a platform baseline intended to keep the repo reusable, supportable, and legible as a product.

## Best-Practice Intent

Use these practices to protect the shared platform contract.

The main goal is to make the standard path easier to use than the custom path.

## 1. Prefer Product Paths Over Ad Hoc Changes

- start from the documented Jenkins or ECS product path
- use the existing environment model for `dev`, `qa`, and `prod`
- prefer the checked-in modules, examples, and templates over bespoke stacks
- treat non-standard customization as exception work

Why this matters:

The repository is stronger when teams consume the platform through a clear path instead of treating it like a loose Terraform scratchpad.

## 2. Keep Shared Modules Reusable

- make module inputs explicit and well named
- keep module outputs useful but minimal
- avoid embedding one-team assumptions in shared modules
- prefer composition over copying infrastructure logic between paths
- document the product impact of module changes, not only the implementation detail

Good baseline:

- environment-aware inputs
- clear variable descriptions
- stable output contracts
- reusable naming and tagging conventions

Bad baseline:

- team-specific values hardcoded in shared modules
- broad variables with unclear meaning
- copy-paste Terraform between product paths

## 3. Preserve The Environment Model

- keep `dev`, `qa`, and `prod` as first-class platform concepts
- use the matching backend config for the selected environment
- keep tfvars aligned with the product path being used
- do not blur environment behavior with hidden defaults

Why this matters:

The environment model is part of the platform contract. If it drifts, the repo stops behaving like a product and becomes harder to operate.

## 4. Make Guardrails Visible

- run Terraform formatting and validation on shared changes
- keep linting and policy checks near the delivery path
- document whether a control is required, recommended, or advisory
- prefer visible defaults over tribal knowledge

Minimum baseline for shared platform work:

```bash
terraform fmt -check -recursive
terraform validate
tflint
```

If policy or security checks are not enforced yet, say so directly rather than implying stronger governance than the repo actually has.

## 5. Keep Documentation Product-Oriented

- write docs for platform consumers, not only platform authors
- keep product boundaries, responsibilities, and maturity level explicit
- align docs with what the repo actually implements
- update product docs when a change affects the standard path

Documentation should answer:

- who the product is for
- when to use it
- what inputs are expected
- what outputs and support expectations exist
- what is out of scope

## 6. Use Sensible Terraform Practices

- validate important inputs
- use locals for repeated derived values
- keep resource naming and tags consistent
- prefer data sources over duplicating existing values
- keep sensitive values out of checked-in tfvars where possible

Example validation pattern:

```hcl
variable "environment" {
  type        = string
  description = "Target platform environment"

  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "Environment must be one of: dev, qa, prod."
  }
}
```

## 7. Treat Security As A Platform Default

- prefer least-privilege IAM patterns
- keep tagging, network, and secret expectations explicit
- document security assumptions in the product path
- avoid presenting advisory practices as enforced security controls

Current repo direction:

- scoped IAM should be preferred
- secrets handling should remain explicit
- runtime and infrastructure defaults should be documented
- unsupported security gaps should be called out honestly

## 8. Keep The Golden Path Easy To Follow

- make the default path obvious in docs
- keep examples aligned with the actual module structure
- avoid adding optional complexity ahead of the core path
- optimize for fast onboarding and repeatable review

For this repo, a good change makes it easier to:

- understand the Jenkins product path
- understand the ECS runtime product path
- navigate the environment structure
- see how governance and support fit into delivery

## 9. Separate Shared Product Work From Consumer Exceptions

- add repeatable improvements to the shared baseline
- keep one-off exceptions out of the main product path unless they clearly generalize
- be explicit when a change is for one team, one environment, or one edge case

Promote a change into the shared baseline when it:

- improves both product clarity and reuse
- helps more than one workload or team
- reduces operational ambiguity
- strengthens supportability

## 10. Position The Repo Honestly

- present the repo as a platform-as-product foundation
- show real implementation depth without overstating maturity
- call out missing pieces such as drift detection, stronger policy enforcement, or deeper observability where they are not implemented

The repo is strongest when positioned as:

- a platform engineering foundation
- a consulting-friendly platform-as-product example
- a reusable Jenkins and ECS platform baseline

## Review Checklist

Before merging a platform-facing change, check:

- does it strengthen the documented product path
- does it keep shared modules reusable
- does it preserve the environment model
- does it improve clarity for platform consumers
- does it avoid overclaiming maturity or enforcement

## Related Docs

- [Getting Started](./getting-started.md)
- [Platform Golden Paths](./platform-golden-paths.md)
- [Platform Governance Model](./platform-governance-model.md)
- [Platform Support Model](./platform-support-model.md)
- [Platform Architecture](./architecture.md)
