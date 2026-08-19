# Edge Module

Creates the public entry layer for Jenkins:

- internet-facing Application Load Balancer
- Jenkins target group
- HTTP listener
- optional HTTPS listener when `certificate_arn` is provided
- AWS WAFv2 Web ACL and ALB association

## Security Notes

The ALB is intentionally public because it is the WAF-protected entry point. Jenkins itself remains private behind the ALB.

The HTTP listener is retained for redirect behavior when HTTPS is configured. The module includes scoped tfsec ignores for these intentional design choices.

## Compatibility

The legacy `modules/jenkins-alb-waf/` folder is kept for compatibility. New root composition should use `platform-modules/edge`.
