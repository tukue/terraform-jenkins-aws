# ADR-004: Shift-Left Security with Policy-as-Code

**Status:** Accepted  
**Date:** 2024-01-15  
**Decider:** Platform Engineering Team  

## Context

Cloud infrastructure misconfigurations are a leading cause of security incidents. To catch issues before resources are provisioned, the platform needs policy enforcement at multiple points in the delivery lifecycle:

1. **Pre-commit** — Developer workstation, before code is pushed
2. **CI/CD quality gate** — On every pull request, before merge
3. **Plan-time** — On the generated Terraform plan, before apply

## Decision

Implement a multi-layered policy enforcement stack:

| Layer | Tool | When | Scope |
|-------|------|------|-------|
| Code quality | TFLint | Pre-commit + CI | Naming, resource conventions, missing tags |
| Static analysis | tfsec + Checkov | Pre-commit + CI | Known insecure patterns, compliance rules |
| Secret detection | Gitleaks | Pre-commit + CI | Credentials, API keys, tokens in code |
| Plan validation | OPA/Conftest | CI (plan-time) | Tagging, cost, IAM, networking, production safety |

## OPA Policies

Policies are written in Rego and stored in `policies/terraform/`:

```
policies/terraform/
├── tags.rego           # Required tags, valid environment values
├── cost.rego           # Instance type limits per env, encrypted volumes
├── iam.rego            # No wildcard actions or resources
├── networking.rego     # No 0.0.0.0/0 on sensitive ports, descriptions
├── s3.rego             # Encryption, public access blocks, versioning
├── production.rego     # Prod-specific: no public IPs, deletion protection
├── iam_test.rego       # Unit tests for IAM policies
└── production_test.rego # Unit tests for production policies
```

Example policy (tags.rego):
```rego
deny contains msg if {
    resource := tfplan.resource_changes[_]
    tags := object.get(resource.change.after, "tags", {})
    missing := required_tags - {tag | tags[tag]}
    count(missing) > 0
    msg := sprintf("Resource '%s' is missing required tags: %s", [resource.address, missing])
}
```

## Trade-offs

- **vs. Runtime policy enforcement**: OPA/Conftest operates on Terraform plan JSON — it cannot prevent runtime drift or detect changes made outside Terraform. Cloud custodian or AWS Config would be needed for continuous compliance.
- **vs. Sentinel**: HashiCorp Sentinel is Terraform-native but requires Terraform Cloud/Enterprise. OPA/Conftest is open-source and provider-agnostic.
- **False positives**: Static analysis tools may flag patterns that are intentionally permissive (e.g., ALB being public). Checkov skips and TFLint ignores are documented inline with rationale.

## Consequences

- Every PR must pass all policy checks before merge (blocking check in CI)
- Plan-time policies require `terraform show -json` output, which adds ~30 seconds to the pipeline
- OPA policies are tested with Rego unit tests in CI (`opa test policies/terraform --verbose`)
- New policies must include corresponding unit tests
