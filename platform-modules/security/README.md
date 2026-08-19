# Security Module

Creates security groups for the Jenkins platform stack:

- ALB security group for approved HTTP/HTTPS CIDRs
- Jenkins security group that allows port `8080` only from the ALB security group
- optional legacy SSH/HTTP/HTTPS group for compatibility

## Security Notes

The default ALB ingress allow-list is empty. Consumers should set `allowed_alb_cidr_blocks` explicitly.

Jenkins egress defaults to VPC-only through the root composition unless `allowed_jenkins_egress_cidr_blocks` is intentionally widened.

## Compatibility

The legacy top-level `security-groups/` folder is kept for compatibility. New root composition should use `platform-modules/security`.
