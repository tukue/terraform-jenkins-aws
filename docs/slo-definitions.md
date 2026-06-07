# Platform SLO Definitions

## Service Level Objectives

### 1. Infrastructure Provisioning

| Metric | SLO Target | Measurement | Window |
|--------|-----------|-------------|--------|
| Terraform plan success rate | 99.5% | Successful plans / total plans | 30 days |
| Terraform apply success rate | 99.0% | Successful applies / total applies | 30 days |
| New environment provisioning time | < 15 min | PR merged to resources ready | Per request |

### 2. CI/CD Pipeline

| Metric | SLO Target | Measurement | Window |
|--------|-----------|-------------|--------|
| Pipeline success rate | 95% | Successful runs / total runs | 30 days |
| Pipeline duration (validation) | < 10 min | Pipeline start to completion | Per run |
| Pipeline duration (deploy) | < 20 min | Pipeline start to apply complete | Per run |

### 3. Security & Compliance

| Metric | SLO Target | Measurement | Window |
|--------|-----------|-------------|--------|
| Time to fix critical findings | < 24 hours | Detection to remediation | Per finding |
| Security scan pass rate | 100% | Passing scans / total scans | Per scan |
| Policy compliance rate | 99.9% | Compliant resources / total resources | 30 days |

### 4. Developer Experience

| Metric | SLO Target | Measurement | Window |
|--------|-----------|-------------|--------|
| Self-service template success | 95% | Successful scaffolding / total attempts | 30 days |
| Documentation accuracy | 99% | Docs validated / total docs checked | 30 days |
| Onboarding time (new project) | < 2 hours | Request to first deploy | Per project |

### 5. Platform Availability

| Metric | SLO Target | Measurement | Window |
|--------|-----------|-------------|--------|
| Jenkins uptime | 99.9% | Uptime / total time | 30 days |
| Backstage portal uptime | 99.5% | Uptime / total time | 30 days |
| Prometheus metrics availability | 99.0% | Scrape success rate | 30 days |
| Grafana dashboard availability | 99.5% | Dashboard load success rate | 30 days |

## SLI Implementation

| SLI | Data Source | Collection Method |
|-----|-------------|-------------------|
| Pipeline success rate | GitHub Actions API | workflow_run events |
| Provisioning duration | GitHub Actions timestamps | Job duration metrics |
| Security scan results | Checkov/tfsec output | Compare pass/fail ratio |
| Template usage | Backstage events | Scaffolder action logs |
| Uptime | CloudWatch / Prometheus | Uptime check metrics |

## Error Budget

Each SLO has a 100% - target error budget over the measurement window.

| SLO Target | Error Budget (30 days) |
|-----------|----------------------|
| 99.9% | 43.2 minutes |
| 99.5% | 3.6 hours |
| 99.0% | 7.2 hours |
| 95% | 36 hours |

## Reporting

SLO status is reported in:
- Grafana operational dashboard
- Weekly platform review
- Monthly executive summary
