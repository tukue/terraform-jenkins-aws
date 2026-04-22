# 🏗️ Platform-as-Product: AWS Infrastructure

This repository is a **Platform Engineering showcase**. It demonstrates how to transform raw Terraform into **Platform Products** that are discoverable, self-serviceable, and production-ready.

---

## 🎯 The Core Philosophy
We don't just "provide infrastructure"; we build **Products** for internal developers. This repo focuses on two main product tracks:
1.  **Jenkins on AWS**: Standardized CI/CD infrastructure.
2.  **Customer ECS Runtime**: Repeatable, multi-tenant container runtimes.

---

## 🧭 Navigate by Persona

| Persona | Start Here | Why? |
| :--- | :--- | :--- |
| **Execs / Stakeholders** | [Platform Implementation Status](docs/platform-as-product-implementation-status.md) | ROI, maturity, and roadmap. |
| **Platform Engineers** | [Architecture Guide](docs/architecture.md) | Deep dive into the modules, networking, and security. |
| **Developers / Users** | [Getting Started](docs/getting-started.md) | Onboarding to "Golden Paths" and self-service. |
| **Operations / SRE** | [Deployment Guide](DEPLOYMENT-GUIDE.md) | Day 2 ops, scaling, and environment management. |

---

## 🚀 Key Features

### 🛠️ Self-Service (The "Frontend")
- **Backstage Integration**: All infra is registered in the [Backstage Catalog](catalog-info.yaml).
- **Golden Path Templates**: Scaffolder templates in `/templates` for one-click provisioning.
- **Local Portal**: Run a developer portal locally via [BACKSTAGE-QUICKSTART.md](BACKSTAGE-QUICKSTART.md).

### 📦 Productized Modules (The "Backend")
- **Environment-Aware**: Native support for `dev`, `qa`, and `prod` with dedicated configs.
- **Reusable Building Blocks**: Located in `platform-modules/` for consistent consumption.
- **Observability**: Integrated Prometheus, Grafana, and CloudWatch in `observability-service/`.

### 🛡️ Governance & Standards
- **Policy-as-Code**: OPA policies for tags, cost, and security in `policies/`.
- **Operating Model**: Defined [SLAs, Support, and Tiers](docs/platform-service-tiers.md).
- **Security Baseline**: Scoped IAM, WAF integration, and ECR scanning.

---

## 📂 Repository Structure

```bash
├── docs/                # 📖 Product docs, architecture, and runbooks
├── platform-modules/    # 🧱 Reusable infrastructure building blocks
├── platform-examples/   # 💡 Example consumption patterns
├── templates/           # 📝 Backstage Scaffolder templates
├── backstage-app/       # 🖥️ Local Backstage portal assets
├── jenkins/             # 🏗️ Jenkins product implementation
├── networking/          # 🌐 Shared VPC and networking modules
└── observability/       # 📊 Metrics, logs, and dashboards
```

---

## 🛠️ Quick Actions
- **View Roadmap**: [IMPLEMENTATION-BACKLOG.md](IMPLEMENTATION-BACKLOG.md)
- **Check Standards**: [CONTRIBUTING.md](CONTRIBUTING.md)
- **Local Test**: `make local-up` (Requires Docker)

---

> **Note**: This is a **Showcase Repository**. It is designed to demonstrate platform engineering maturity, not as a 1:1 "copy-paste" for any production environment without proper hardening.
