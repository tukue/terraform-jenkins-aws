# Compute Module

Creates the Jenkins EC2 instance and SSH key pair.

This module is intentionally focused on compute:

- AMI and instance type
- subnet placement
- security group attachment
- public IP setting
- Jenkins bootstrap user data
- optional Ansible provisioner

Network, security group rules, and load balancing are owned by separate modules.

## Security Notes

For the default private Jenkins architecture, pass a private subnet ID and set `enable_public_ip_address = false`.

## Compatibility

The legacy top-level `jenkins/` folder is kept for compatibility. New root composition should use `platform-modules/compute`.
