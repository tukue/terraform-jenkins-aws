# ADR-005: Module Design for Reusability and Composition

**Status:** Accepted  
**Date:** 2024-01-15  
**Decider:** Platform Engineering Team  

## Context

The platform needs a set of reusable infrastructure building blocks that can be composed to deliver consistent, compliant environments. The module design must balance:
- **Reusability**: Modules should work across environments and use cases
- **Opinionation**: Modules should encode best practices by default
- **Flexibility**: Consumers should be able to override defaults
- **Discoverability**: Modules should be documented and cataloged

## Decision

Design modules with these conventions:

### Module Structure

```
platform-modules/<name>/
├── main.tf           # Resources and logic
├── variables.tf      # Inputs with descriptions, types, and defaults
├── outputs.tf        # Published values for composition
├── versions.tf       # Provider and Terraform version constraints
├── README.md         # Usage documentation and examples
├── catalog-info.yaml # Backstage catalog metadata
└── OWNERS.yaml       # Ownership and review requirements
```

### Design Principles

1. **Tags propagate from caller**: `var.tags` is merged with module-specific tags, never overridden.
2. **Sensible defaults**: Module defaults encode best practices (KMS encryption, IMDSv2, deletion protection) but can be overridden.
3. **Input validation**: Variables include `validation` blocks for CIDR format, security group IDs, and known values.
4. **Output consistency**: Outputs have descriptive names and descriptions. Deprecated outputs are marked and maintained for backward compatibility.
5. **Version constraints**: Provider versions are pinned with `~>` to allow patch upgrades while preventing breaking changes.

### Example: Security Group Module

The `security-group` module accepts dynamic ingress/egress rules:
```hcl
module "web_sg" {
  source = "platform-modules/security-group"

  name        = "web-service-sg"
  description = "Security group for the web service tier"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      cidr_blocks     = ["10.0.0.0/8"]
      description     = "HTTPS from internal network"
      security_groups = []
      self            = false
    }
  ]

  egress_rules = [
    {
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
      description     = "All outbound traffic"
      security_groups = []
      self            = false
    }
  ]

  tags = { Environment = "dev" }
}
```

## Trade-offs

- **vs. Monolithic root module**: Splitting into small modules creates more files and indirection, but enables targeted reuse, isolated testing, and independent versioning.
- **vs. Community modules**: Custom modules are maintained by the platform team. Where possible, community modules (e.g., terraform-aws-vpc) are preferred for well-established patterns.
- **vs. Terragrunt**: Modules at this level are tool-agnostic. Terragrunt (or similar) can be added later as an orchestration layer without changing module internals.

## Consequences

- Each module needs a README with examples (makes the portfolio more accessible)
- Modules with breaking changes require a major version bump and migration guide
- Backstage catalog-info.yaml enables service discovery through the developer portal
- Code reviews enforce module design standards (tags, validation, outputs)
