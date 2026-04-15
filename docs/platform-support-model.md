# Platform Support Model

This document defines how support should be understood for the platform product paths in this repository.

## Support Intent

The purpose of the support model is to make expectations explicit.

This repository is designed as a platform product foundation and portfolio artifact. It includes real implementation depth, but it does not represent a full managed service with enterprise support commitments.

## Support Scope

The support model applies to:

- shared Terraform modules
- product documentation and examples
- Jenkins and ECS platform product paths
- standards, runbooks, and operating guidance in the repository

The support model does not fully apply to:

- workload-specific application issues
- heavy customization outside the documented platform path
- production incident response for downstream consumer systems
- organizational processes not represented in this repository

## Support Levels

| Level | Scope | Expectation |
|---|---|---|
| Best effort | Docs, examples, and repo guidance | Clarification and improvement work |
| Supported baseline | Standard Jenkins and ECS product paths | Reasonable maintenance of the documented default path |
| Consumer-owned exception | Advanced customization and one-off deviations | Owned by the consuming team unless adopted into the platform baseline |

## Ownership Split

The platform layer owns:

- reusable modules
- shared templates and product docs
- standards and operating guidance
- the definition of the golden path

Consuming teams own:

- application behavior and workload-specific settings
- non-standard deviations from the documented path
- access approvals, secrets handling decisions, and org-specific governance
- operational support beyond the shared baseline

## Supported Requests

Support should prioritize:

- clarifying documented product behavior
- fixing broken or misleading docs
- improving default path usability
- correcting issues in reusable modules that affect the standard path
- adding guardrails where the product contract is unclear

## Unsupported Requests

The following should be treated as outside the standard support model:

- broad custom feature work for a single team
- open-ended consulting disguised as product support
- production operations for consumer-managed systems
- break-fix support for heavily modified downstream copies

## Response Expectations

For this repository, support expectations should be described qualitatively rather than with formal SLA terms.

- documentation issues should be addressed quickly when they block adoption
- reusable module defects on the standard path should be treated as high priority
- consumer-specific customization requests should be triaged as exception work
- production-grade response commitments are out of scope for the current repo

## Escalation Model

When a request falls outside the default path:

1. confirm whether it affects the shared product baseline
2. decide whether it should become a supported platform capability
3. if not, classify it as consumer-owned exception work

## Success Signals

The support model is working when:

- consumers know what is and is not supported
- reusable platform issues are separated from team-specific issues
- the documented golden path becomes easier to maintain
- exceptions do not silently become product commitments

## Related Docs

- [Platform Operating Model](./platform-operating-model.md)
- [Platform-as-Product Readiness Plan](./platform-as-product-readiness.md)
- [Platform Product Jenkins](./platform-product-jenkins.md)
- [Platform Product ECS Runtime](./platform-product-ecs-runtime.md)
