# Platform Versioning and Deprecation

This document defines how shared platform assets in this repository should evolve over time.

The goal is to make platform change predictable for consumers of the Jenkins and ECS product paths.

## Why This Matters

A platform behaves like a product only when consumers can understand:

- when a shared module or template has changed
- whether a change is compatible with existing usage
- how long older patterns remain supported
- what to do when a path is being retired

Without that, every change feels ad hoc even if the Terraform itself is reusable.

## Scope

This guidance applies to shared platform assets such as:

- Terraform modules under `platform-modules/`
- product-facing templates under `templates/`
- product docs in `docs/`
- shared environment and delivery conventions

## Versioning Principles

- prefer predictable change over silent change
- treat shared platform interfaces as contracts
- make breaking changes explicit
- keep documentation aligned with the current supported baseline
- deprecate intentionally instead of leaving stale paths in place

## What Counts As A Versioned Contract

In this repository, the most important contracts are:

- Terraform module inputs and outputs
- template parameters and generated repo structure
- environment naming and expected promotion flow
- documented golden-path behavior

If one of those changes, the platform contract has changed.

## Change Categories

### Compatible Change

A compatible change improves the platform without breaking the documented path for existing consumers.

Examples:

- adding a new optional variable with a safe default
- adding a new output
- improving docs without changing behavior
- strengthening validation for clearly invalid input

### Behavior Change

A behavior change alters the default experience but may still be compatible if the impact is small and clearly documented.

Examples:

- changing a default tag value
- tightening a template input description or validation rule
- adjusting autoscaling defaults for a product path

These changes should be documented wherever the product path is described.

### Breaking Change

A breaking change requires consumer action or invalidates an existing assumption.

Examples:

- renaming or removing a variable
- removing an output
- changing generated template structure in a way downstream users rely on
- replacing a product path with a new one

Breaking changes should not be hidden inside routine cleanup work.

## Recommended Versioning Approach

This repository does not need a heavy release management system yet.

A practical platform-as-product baseline is:

- use commit history and PR descriptions to make contract changes explicit
- document notable product-contract changes in the affected product docs
- treat breaking changes as named change events, not incidental edits
- keep current docs focused on the supported baseline

For future maturity, this repo could adopt explicit release notes or semantic versioning for selected modules, but that is not required yet to improve product clarity.

## Deprecation Rules

Deprecation should be used when a path still exists but is no longer the recommended way to consume the platform.

When deprecating a shared asset:

1. mark it clearly in docs
2. point to the replacement path
3. explain why the replacement is preferred
4. avoid updating the deprecated path as if it were still the primary baseline

## What Should Be Deprecated Carefully

These areas deserve explicit deprecation handling:

- legacy templates replaced by clearer golden paths
- wrapper modules replaced by better shared modules
- local demo paths superseded by simpler supported paths
- old docs that describe behavior no longer aligned with the current baseline

## Deprecation Language

Use clear wording such as:

- `supported`
- `recommended`
- `legacy`
- `deprecated`
- `replacement path`

Avoid vague wording like:

- `maybe outdated`
- `older option`
- `not ideal`

The consumer should not have to infer whether something is still part of the supported product surface.

## Removal Rules

Remove a deprecated path when:

- a documented replacement exists
- the old path creates confusion or support cost
- keeping it around weakens the product narrative
- the shared baseline no longer depends on it

Do not remove a path without updating the docs that reference it.

## Practical Repo Guidance

For this repository:

- prefer evolving `platform-modules/` over multiplying overlapping implementations
- prefer updating product docs to reflect the current baseline rather than preserving obsolete narratives
- mark legacy local Backstage paths clearly when a simpler supported path exists
- keep Jenkins and ECS product docs aligned with the current module and template contracts

## Review Questions

When changing a shared platform asset, ask:

- does this change alter a consumer-facing contract
- is the change compatible, behavioral, or breaking
- does any product doc need to be updated
- should any older path now be marked deprecated
- would a new consumer understand which path is current

## Related Docs

- [Platform Operating Model](./platform-operating-model.md)
- [Platform Governance Model](./platform-governance-model.md)
- [Platform Golden Paths](./platform-golden-paths.md)
- [Platform Product Jenkins](./platform-product-jenkins.md)
- [Platform Product ECS Runtime](./platform-product-ecs-runtime.md)
