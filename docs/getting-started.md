# 🚀 Onboarding: Getting Started with the Platform

Welcome to the **Internal Developer Platform**. This guide will help you choose the right path into the repository, whether you're a first-time user, a platform engineer, or a stakeholder.

---

## 🧭 Choose Your Entry Point

### Path 1: Local Evaluation (The "Look and Feel")
Best for: *Evaluating the platform experience without AWS costs.*
1.  **Run the Portal**: Follow the **[Backstage Quickstart](../BACKSTAGE-QUICKSTART.md)** to spin up a local instance of the developer portal.
2.  **Explore the Catalog**: Navigate to `http://localhost:3000` to see the Jenkins and ECS components.
3.  **Inspect Templates**: See how we define "Golden Paths" in the `templates/` directory.

### Path 2: Jenkins on AWS (CI/CD Foundation)
Best for: *Provisioning standard Jenkins infrastructure in AWS.*
1.  **Review the Product**: Read the **[Jenkins Product Doc](./platform-product-jenkins.md)**.
2.  **Provision Dev**:
    ```bash
    terraform init -backend-config="backend-config-dev.hcl"
    terraform plan -var-file="terraform.dev.tfvars"
    terraform apply -var-file="terraform.dev.tfvars"
    ```
3.  **Scale and Manage**: Use the **[Scaling Jenkins Runbook](./runbooks/scaling-jenkins.md)**.

### Path 3: Customer ECS Runtime (Container Platform)
Best for: *Delivering a standardized, multi-environment container runtime.*
1.  **Review the Product**: Read the **[ECS Runtime Product Doc](./platform-product-ecs-runtime.md)**.
2.  **Understand the Design**: Review the **[Multi-Tenant Design](./multi-tenant-customer-runtime-design.md)**.
3.  **Inspect Examples**: See reference patterns in `platform-examples/customer-ecs-runtime/`.

---

## 🛠️ Prerequisites

*   **Tools**: Git, Terraform (v1.6+), and Docker (for local evaluation).
*   **AWS Access**: An AWS account with permissions to create VPCs, EC2, ECS, and IAM roles.
*   **Knowledge**: Basic understanding of Terraform modules and environment management.

---

## 📐 Platform Core Concepts

To be successful, understand these three pillars:
1.  **Environments**: We use dedicated `.tfvars` and backend configs for `dev`, `qa`, and `prod`.
2.  **Golden Paths**: Don't build from scratch; use a documented product track.
3.  **Support Tiers**: Different environments have different service levels (L1-L3 support).

---

## 📖 Related Documentation
- **[Architecture & Security](./architecture.md)**: How everything is wired together.
- **[Best Practices](./best-practices.md)**: Naming, tagging, and coding standards.
- **[Operating Model](./platform-operating-model.md)**: How we run the platform.
- **[Support Model](./platform-support-model.md)**: How to get help when you're stuck.

---
*Created: March 2024*  
*Contact: platform-team@organization.com*
