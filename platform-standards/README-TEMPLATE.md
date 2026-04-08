# Module: [MODULE_NAME]

## Product Value Proposition
[Describe the business value. Why should a developer use this module? What specific platform problem does it solve?]

## Capabilities
- **[Capability 1]**: [Short description]
- **[Capability 2]**: [Short description]

## Getting Started
To deploy this module, follow the internal platform self-service deployment procedures.

Alternatively, invoke the module directly in your Terraform configuration:

```hcl
module "my_service" {
  source = "../../platform-modules/[MODULE_NAME]"
  # ... configuration ...
}
```

## Governance & Support
- **Owner**: [Reference team]
- **Support**: See [OWNERS.yaml](./OWNERS.yaml) for specific contact and maintenance details.
- **Compliance**: This module adheres to the platform's standard OPA security and cost policies.

## Documentation
- [Deployment Guide](../docs/deployment-guide.md)
- [Architecture Details](../docs/architecture.md)
