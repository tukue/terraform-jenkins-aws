# Changelog

This changelog records platform-facing changes that affect the supported product surface of this repository.

It is intentionally lightweight. The goal is not release ceremony. The goal is to make consumer-facing changes easier to review.

## How To Use This File

Add an entry when a change affects:

- Terraform module inputs or outputs
- template parameters or generated structure
- environment conventions
- documented Jenkins or ECS golden-path behavior
- support, governance, service-tier, or versioning expectations

Use these categories:

- `Added`
- `Changed`
- `Deprecated`
- `Removed`
- `Fixed`

## Unreleased

### Added

- Platform product docs for Jenkins, ECS runtime, governance, support, service tiers, versioning, and deprecation guidance.
- `make tfsec` as the explicit local Terraform security scan command.
- Structured interface files for `platform-modules/service-tier-wrapper` with `variables.tf`, `outputs.tf`, and `README.md`.
- A dedicated Backstage `Platform Home` landing page that surfaces supported products, golden-path guidance, and self-service entry points.
- A new `platform-examples/service-tier-wrapper` example that treats the tier wrapper as the default product-facing Terraform path for standard services.

### Changed

- README now presents the repository more clearly as a platform-as-product portfolio and review surface.
- Backstage quickstart and local guidance now prefer the checked-in `backstage-app` and root `Makefile` targets.
- `CONTRIBUTING.md` now aligns more closely with the platform-product model and current scan tooling.
- The local Backstage experience now starts on a product landing page at `/`, while the catalog remains available at `/catalog`.
- The service tier wrapper now exposes clearer product, runtime, and deployment summary outputs, and the examples/docs now distinguish the default wrapper path from the lower-level ECS runtime path.

### Deprecated

- `backstage-local-test` is treated as a legacy helper path rather than the primary local Backstage path.
