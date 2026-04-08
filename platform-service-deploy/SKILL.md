---
name: platform-service-deploy
description: Generate standard Terraform service definitions using the platform's service-tier-wrapper. Use this when a developer needs to deploy a new service and wants to use approved platform defaults for CPU, memory, and security.
---

# Platform Service Deployment

Use this skill to generate the Terraform code for a new service deployment.

## Workflow

1. **Gather Inputs**:
   - `service_name`: A unique name for your service (e.g., `checkout-api`).
   - `tier`: The sizing tier (`small`, `med`, `large`).
   - `container_image`: Full URI to the Docker image (e.g., `ghcr.io/my-org/service:v1.0.0`).
   - `environment`: The target environment (`dev`, `qa`, or `prod`).

2. **Generate Terraform**:
   The skill will output the standard `module` block for your `main.tf`:

   ```hcl
   module "my_service" {
     source          = "../../platform-modules/service-tier-wrapper"
     service_name    = "your-service-name"
     tier            = "small"
     container_image = "your-image:tag"
     environment     = "dev"
   }
   ```

3. **Verify Compliance**:
   Run `terraform plan` followed by the platform's OPA policy checks to ensure your new service adheres to security and cost standards.
