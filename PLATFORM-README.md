# 📂 Platform Product Catalog

This repository represents an **AWS-based Platform Engineering** framework. We treat infrastructure as a **Product**, not just a set of scripts.

---

## 🏗️ The Platform Product Layers

The platform is structured in four layers to enable scale and developer experience:

### 1. Product Tracks (Golden Paths)
High-level "Capabilities" designed for developer consumption.
*   **[Jenkins on AWS](docs/platform-product-jenkins.md)**: Repeatable, scalable, and secure CI/CD foundations.
*   **[Customer ECS Runtime](docs/platform-product-ecs-runtime.md)**: Multi-tenant, secure container runtime with built-in networking and observability.

### 2. Self-Service Layer (Backstage)
The developer portal provides a "Marketplace" for the platform products.
*   **[Backstage Catalog](catalog-info.yaml)**: All resources are registered and discoverable.
*   **[Scaffolder Templates](templates/README.md)**: One-click creation of new Jenkins or ECS environments.

### 3. Implementation Foundation (Terraform)
Reusable, environment-aware building blocks.
*   **[Platform Modules](platform-modules/)**: Tested and versioned modules for core infra.
*   **[Platform Examples](platform-examples/)**: Reference patterns for multi-environment delivery.

### 4. Governance & Operating Model
Documentation defining how we operate and support the platform.
*   **[Service Tiers](docs/platform-service-tiers.md)**: Different support levels for `dev` vs `prod`.
*   **[Support Model](docs/platform-support-model.md)**: How to get help (L1-L3 support).
*   **[Governance Model](docs/platform-governance-model.md)**: How we manage standards and compliance.

---

## 🎯 Value Proposition

We shift the focus from **provisioning raw resources** to **delivering platform capabilities**:
*   **Faster Lead Time**: Developers use "Golden Paths" instead of starting from scratch.
*   **Better Security**: Hardened defaults and policy-as-code are built-in.
*   **Operational Consistency**: Common observability, logging, and scaling patterns.
*   **Scalable Support**: Documentation and self-service reduce manual support overhead.

---

## 🧭 Entry Points

| Journey | Start Here |
| :--- | :--- |
| **New to the platform?** | [Getting Started Guide](docs/getting-started.md) |
| **Want to see the portal?** | [Backstage Quickstart](BACKSTAGE-QUICKSTART.md) |
| **Deploying to AWS?** | [Deployment Guide](DEPLOYMENT-GUIDE.md) |
| **Contributing code?** | [Contributing Guide](CONTRIBUTING.md) |

---
*Positioning: Internal Developer Platform Reference Implementation*
