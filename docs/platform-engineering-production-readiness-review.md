# Platform Engineering and Production Readiness Review

**Review date:** June 7, 2026  
**Scope:** Terraform platform modules, Jenkins and ECS product paths, Backstage, CI/CD, policy as code, security, observability, operations, and platform governance.

## Executive Summary

This repository is a credible platform engineering foundation and portfolio implementation. It has reusable Terraform modules, self-service Backstage templates, environment-specific configuration, remote-state controls, private Jenkins networking, an ECS runtime product, CI validation, ownership metadata, and initial policy-as-code and observability assets.

It is not yet production-ready as a shared enterprise platform. The largest gaps are deployment integrity, incomplete policy enforcement, insecure or demonstration-oriented defaults, shallow alerting, missing service-level objectives, limited recovery automation, no drift detection, and governance controls that are documented more strongly than they are enforced.

**Overall assessment: Developing / pre-production.**

The platform is suitable for controlled development and demonstration environments. Production use should be conditional on closing the P0 findings and establishing account-level controls outside this repository, including branch protection, GitHub environment approvals, identity federation, centralized audit logging, and tested recovery procedures.

## Assessment Scale

| Rating | Meaning |
|---|---|
| Established | Implemented consistently and suitable as a production baseline |
| Developing | Implemented in part, but important controls or coverage are missing |
| Initial | Assets or documentation exist, but enforcement and operational proof are weak |
| Not implemented | No effective repository implementation was found |

## Capability Scorecard

| Capability | Rating | Current evidence | Main gap |
|---|---|---|---|
| Platform as a product | Developing | Jenkins and ECS product paths, service tiers, support and golden-path docs | Product metrics, adoption telemetry, and enforceable service contracts |
| Developer self-service | Developing | Backstage catalog and scaffolder templates | Production Backstage posture, authorization model, and safe automated fulfillment |
| Reusable infrastructure | Developing | `platform-modules/`, examples, ownership files, input validation | Automated module tests, release artifacts, compatibility testing, and stronger version pinning |
| Environment isolation | Developing | Separate dev, QA, and prod tfvars/backend files | Account separation is not enforced by repository structure; promotion evidence is weak |
| CI/CD safety | Initial | Formatting, TFLint, tfsec, OIDC, plan/apply workflow | Apply creates a new plan, PRs do not receive deployable plans, and artifact provenance is not protected |
| Security and least privilege | Developing | Private Jenkins instance, WAF, scoped ECS task roles, encrypted state, IMDSv2 | Public defaults, wildcard IAM in Backstage, static/demo secrets, and no IAM policy-as-code |
| Policy as code | Initial | Four Terraform Rego policies and Conftest in manual delivery | Narrow resource coverage, no policy tests, no CI policy check for every PR |
| Observability | Initial | CloudWatch alarms/dashboard, Prometheus, Grafana, ECS Container Insights | Observability is optional, alarms have no notification actions, and logs/traces/SLOs are incomplete |
| Reliability and recovery | Initial | Multi-AZ ECS defaults, state versioning, DynamoDB PITR, rollback runbook | Jenkins is a single instance, ALB deletion protection is disabled, and recovery is not tested |
| Operations | Initial | Delivery and scaling runbooks, ownership metadata | Incident response, on-call, escalation, DR exercises, patching, and certificate runbooks |
| Cost management | Initial | Cost policy and tags | Budgets, anomaly detection, PR cost estimates, ownership reporting, and automated non-prod controls |
| Governance | Developing | CODEOWNERS, standards, governance docs, PR template | Branch/environment rules are external and unverified; docs overstate several enforced controls |

## Key Findings

### P0 - Apply Does Not Consume an Approved Plan

The delivery workflow creates one plan for a `plan` dispatch and creates a different plan immediately before `apply`. The reviewed artifact is therefore not the artifact being applied. The apply job also needs only the quality gate, not a successful environment plan.

**Evidence:** `.github/workflows/jenkins-platform-delivery.yml`

**Risk:** Infrastructure can change between review and apply due to source changes, provider behavior, data sources, or remote-state changes. There is no cryptographic or workflow-level link between approval and deployment.

**Required outcome:**

- Create the plan from an immutable commit SHA.
- Store the binary plan and plan JSON as retained artifacts with checksums.
- Require policy, security, cost, and human approval against that plan.
- Apply only the approved binary plan from the same workflow run.
- Use separate plan and apply roles; the plan role must not have mutation permissions.

### P0 - Production Guardrails Are Not Reliably Enforced

OPA policies run only in manually dispatched plan/apply jobs. Pull requests run formatting, TFLint, and tfsec, but do not produce a Terraform plan or execute Conftest. The standalone security workflow only runs tfsec.

The pull request template says Gitleaks and Checkov are blocking CI checks, but neither is present in the checked-in workflows reviewed.

**Evidence:** `.github/workflows/terraform-scan.yml`, `.github/workflows/jenkins-platform-delivery.yml`, `.github/pull_request_template.md`, `policies/terraform/`

**Risk:** A change can merge without plan-time policy evaluation, secret scanning, Checkov, or evidence that production policy passed. Documentation can create a false sense of control.

**Required outcome:**

- Run validation, secret scanning, dependency scanning, Checkov/tfsec, plan generation, and Conftest on every relevant pull request.
- Protect the default branch with required checks and CODEOWNER approval.
- Require a GitHub `prod` environment approval and prevent self-approval.
- Add explicit, expiring, owner-approved policy exceptions.

### P0 - Insecure and Demonstration-Oriented Defaults Remain

Examples include Grafana access from `0.0.0.0/0`, a default Grafana password of `change-me`, public Backstage rules, ECS images using `:latest`, public ALB defaults, and a Backstage IAM statement with `Resource = "*"`.

**Evidence:** `variables.tf`, `grafana/main.tf`, `grafana/variables.tf`, `platform-modules/customer-ecs-runtime/variables.tf`, `platform-modules/customer-ecs-runtime/main.tf`, `backstage/vpc.tf`, `templates/`

**Risk:** Consumers following the golden path can deploy mutable, publicly exposed, or over-privileged infrastructure.

**Required outcome:**

- Fail validation for production when public CIDRs, mutable image tags, HTTP-only endpoints, or placeholder credentials are used.
- Source credentials from Secrets Manager or Vault and remove password defaults.
- Pin deployable images by digest.
- Replace wildcard IAM with action and resource allow-lists.
- Make private connectivity the default for administrative services.

### P1 - Observability Exists but Is Not an Operable Production Service

Jenkins observability is disabled by default. CloudWatch alarms cover only EC2 CPU and status checks and do not define `alarm_actions` or `ok_actions`. The repository has local Prometheus/Grafana assets and ECS Container Insights, but no consistent alert routing, service-level indicators, tracing, centralized log search, synthetic checks, or alert ownership.

**Evidence:** `cloudwatch-observability/main.tf`, `variables.tf`, `observability-service/`, `prometheus/`, `grafana/`, `platform-modules/customer-ecs-runtime/main.tf`

**Risk:** Failures may be visible on a dashboard but not detected, routed, triaged, or measured against customer impact.

**Required outcome:**

- Define SLOs and error budgets for Jenkins, Backstage, and the ECS runtime.
- Alert on symptoms such as availability, latency, queue depth, failed deployments, ALB 5xx rates, unhealthy targets, task restarts, and saturation.
- Route alarms through SNS or an incident-management integration with owner and severity metadata.
- Standardize structured logs, retention by environment, correlation IDs, and OpenTelemetry traces.
- Add observability validation to each golden-path template.

### P1 - Reliability and Disaster Recovery Are Incomplete

Terraform state has versioning, KMS encryption, public-access blocking, access logging, and DynamoDB point-in-time recovery. ECS has autoscaling and a deployment circuit breaker. However, Jenkins and Backstage EC2 are single-instance services, ALB deletion protection is disabled, and no automated backup/restore test or regional recovery implementation was found.

Backstage RDS deletion protection checks for `environment == "production"`, while the repository environment contract uses `prod`; this prevents the intended protection from activating for `prod`.

**Evidence:** `s3.tf`, `platform-modules/customer-ecs-runtime/main.tf`, `platform-modules/edge/main.tf`, `backstage/modules/backstage-ec2/main.tf`, `backstage/modules/backstage-postgres/main.tf`

**Risk:** A component or Availability Zone failure can create prolonged outage or data loss. Recovery claims are not supported by tested procedures.

**Required outcome:**

- Correct the `prod` deletion-protection condition.
- Define recovery time and recovery point objectives per platform service.
- Protect production load balancers and data stores from accidental deletion.
- Automate Jenkins configuration and data backup, restore, and validation.
- Run scheduled recovery exercises and record evidence.

### P1 - Platform Modules Lack Automated Contract Tests and Release Discipline

The repository has reusable modules, examples, variable validation, and ownership metadata, but no clear Terraform test suite, integration test pipeline, module release workflow, or automated upgrade compatibility matrix was found. Root Terraform allows any Terraform version from `1.0.0` upward while CI uses a single newer version.

**Evidence:** `platform-modules/`, `platform-examples/`, `versions.tf`, `.github/workflows/`

**Risk:** Shared-module changes can break consumers despite passing formatting and static analysis.

**Required outcome:**

- Add `terraform test` unit/contract tests and ephemeral integration tests for critical modules.
- Test supported Terraform and provider versions explicitly.
- Publish versioned module releases and changelogs.
- Use automated dependency update pull requests with validation.
- Define compatibility, deprecation, and migration policy as enforced release practice.

### P1 - Drift, Audit, and Runtime Security Controls Are Missing

The repository acknowledges that drift detection is not implemented. No scheduled plan, AWS Config/Security Hub integration, organization-level CloudTrail design, runtime vulnerability response, or automated patch compliance control was found in the reviewed paths.

**Risk:** Manual changes, compromised resources, and configuration degradation can remain undetected.

**Required outcome:**

- Run scheduled read-only plans and route drift findings to service owners.
- Centralize CloudTrail, Config, GuardDuty, Security Hub, and access logs in a security account.
- Add image and dependency vulnerability gates with remediation SLAs.
- Define patching, break-glass, and credential-revocation procedures.

### P2 - Platform Product Feedback Loops Are Mostly Documentation

The repository has strong product-oriented documents, service tiers, support guidance, catalog entities, and templates. It does not yet measure adoption, provisioning lead time, deployment success, template abandonment, support demand, exception rate, or developer satisfaction.

**Risk:** The platform can accumulate features without proving that the golden paths improve developer outcomes.

**Required outcome:**

- Define platform product KPIs and instrument Backstage and CI/CD events.
- Track time to first deployment, change failure rate, deployment frequency, recovery time, policy failure rate, and golden-path adoption.
- Review metrics with platform consumers and maintain a prioritized product roadmap.

## Strengths to Preserve

- Clear platform-product framing instead of a collection of unrelated Terraform files.
- Reusable modules, examples, templates, catalog metadata, and ownership files.
- Explicit `dev`, `qa`, and `prod` configuration with AWS account validation.
- Private Jenkins runtime behind ALB and WAF.
- ECS execution and task role separation with scoped secret, parameter, and KMS inputs.
- Encrypted and versioned Terraform state with locking and public-access prevention.
- ECS autoscaling defaults, Container Insights, log groups, and deployment circuit breaker.
- CI concurrency limits, timeouts, OIDC capability, Terraform formatting, TFLint, and tfsec.
- Honest architecture documents that identify several current maturity limits.

## Prioritized Remediation Roadmap

### Phase 1 - Deployment and Security Baseline

1. Make PR plan, policy, secret, and security checks mandatory.
2. Apply only an approved, immutable plan artifact.
3. Split CI plan and apply IAM roles and enforce environment/account boundaries.
4. Remove placeholder credentials, mutable image tags, public administrative access, and wildcard IAM.
5. Correct production deletion protection and enable protection for critical resources.
6. Pin third-party GitHub Actions to reviewed commit SHAs.

### Phase 2 - Operability and Reliability

1. Define SLIs, SLOs, error budgets, owners, and alert routes.
2. Add service-level dashboards and actionable alarms for Jenkins, Backstage, ECS, ALB, RDS, and CI/CD.
3. Implement centralized logs and OpenTelemetry traces.
4. Add automated backup/restore validation and scheduled disaster-recovery exercises.
5. Implement scheduled drift detection and security-account audit services.

### Phase 3 - Platform Product Maturity

1. Add Terraform module contract and integration tests.
2. Version and release modules with compatibility and deprecation automation.
3. Add PR cost estimates, budgets, anomaly detection, and non-production schedules.
4. Instrument platform adoption and delivery performance.
5. Productionize Backstage authorization, publishing, high availability, and software-template fulfillment.

## Minimum Production Entry Criteria

The platform should not be described as production-ready until all of the following are evidenced:

- Every production apply uses the exact reviewed plan artifact.
- Required branch checks and independent production approval are enabled.
- CI uses short-lived OIDC credentials and separate least-privilege plan/apply roles.
- Policy as code blocks wildcard IAM, unsafe networking, missing encryption, mutable artifacts, missing backups, and production availability violations.
- No default credential or unrestricted administrative ingress reaches production.
- Critical services have SLOs, routed alerts, dashboards, runbooks, and named owners.
- Backup restoration and disaster recovery have been tested against documented RTO/RPO targets.
- Drift detection and centralized audit/security telemetry are operating.
- Critical modules have automated tests and versioned releases.
- Exceptions are time-bound, approved, attributable, and auditable.

## Review Limitations

This is a static repository review. It does not verify deployed AWS resources, GitHub branch protection, GitHub environment reviewers, organization policies, IAM role trust policies, live alert delivery, vulnerability findings, backup restoration, or operational response performance. Those controls require runtime evidence before production approval.
