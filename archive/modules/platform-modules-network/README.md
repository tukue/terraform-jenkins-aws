# Network Module (Deprecated)

> **Deprecated**: Use `./cicd/core/network` instead. This module is preserved for backward compatibility only.

Creates the VPC network foundation with:

- VPC with DNS support
- public and private subnets
- internet gateway
- optional NAT gateway for private subnet egress
- route tables and associations
- VPC flow logs
- baseline network ACL rules

This module owns network boundaries only. It does not create application security groups or compute resources.

## Security Notes

Private subnet egress is optional through `enable_nat_gateway`. Security group egress still controls which destinations workloads can reach.

## Migration

Replace with the CICDaaS network module:
```hcl
module "networking" {
  source = "./cicd/core/network"
  ...
}
```
