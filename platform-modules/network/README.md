# Network Module

Creates the Jenkins VPC network foundation:

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

## Compatibility

The legacy top-level `networking/` folder is kept for compatibility. New root composition should use `platform-modules/network`.
