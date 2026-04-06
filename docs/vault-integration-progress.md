# Vault Integration Progress

This document tracks the Vault integration work for the Terraform Jenkins AWS platform.

## Current Status

| Area | Status | Notes |
|---|---|---|
| Vault provider wiring | Implemented | Terraform Vault provider support exists in the root stack |
| Optional Vault reads | Implemented | Vault access is feature-flagged so non-Vault runs still work |
| Local Vault testing | Partial | Local test flow exists, but should be verified after code changes |
| Secret consumption in Jenkins | Not Started | No Jenkins resource is consuming Vault data yet |
| Secret rotation strategy | Not Started | Rotation and policy hardening are not implemented |
| Production Vault auth | Not Started | Local dev auth is used for testing; production auth still needs design |

## What To Verify

Use this checklist to measure progress as the integration evolves:

- [ ] Terraform can initialize with Vault support enabled
- [ ] Terraform can read a KV v2 secret from a local Vault server
- [ ] Vault integration remains optional when disabled
- [ ] No secret values are printed in plain-text outputs
- [ ] Jenkins receives at least one Vault-managed secret
- [ ] Vault auth is replaced with a production-ready approach
- [ ] Vault-related docs reflect the current implementation

## Suggested Next Steps

1. Verify the local Vault plan path still works after any Terraform changes.
2. Wire one secret into the Jenkins bootstrap flow.
3. Add policy and auth hardening for non-local environments.
4. Remove any temporary debug outputs once verification is complete.

## Relevant Files

- [`vault.tf`](/c:/Users/tukue/terraform-jenkins-aws/vault.tf)
- [`versions.tf`](/c:/Users/tukue/terraform-jenkins-aws/versions.tf)
- [`outputs.tf`](/c:/Users/tukue/terraform-jenkins-aws/outputs.tf)
- [`docs/getting-started.md`](/c:/Users/tukue/terraform-jenkins-aws/docs/getting-started.md)
- [`vault-local-test/README.md`](/c:/Users/tukue/terraform-jenkins-aws/vault-local-test/README.md)

## Notes

- Keep Vault secrets out of committed tfvars files.
- Prefer environment variables or local-only config for dev testing.
- Revisit the document after each integration milestone so the status stays accurate.
