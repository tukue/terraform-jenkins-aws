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

### Changed

- README now presents the repository more clearly as a platform-as-product portfolio and review surface.
- Backstage quickstart and local guidance now prefer the checked-in `backstage-app` and root `Makefile` targets.
- `CONTRIBUTING.md` now aligns more closely with the platform-product model and current scan tooling.

### Deprecated

- `backstage-local-test` is treated as a legacy helper path rather than the primary local Backstage path.
