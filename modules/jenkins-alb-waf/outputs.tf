output "alb_dns_name" {
  description = "DNS name of the Jenkins ALB"
  value       = aws_lb.jenkins.dns_name
}

output "alb_zone_id" {
  description = "Hosted zone ID of the Jenkins ALB"
  value       = aws_lb.jenkins.zone_id
}

output "alb_arn" {
  description = "ARN of the Jenkins ALB"
  value       = aws_lb.jenkins.arn
}

output "target_group_arn" {
  description = "ARN of the Jenkins target group"
  value       = aws_lb_target_group.jenkins.arn
}

output "waf_web_acl_arn" {
  description = "ARN of the Jenkins WAF Web ACL"
  value       = try(aws_wafv2_web_acl.jenkins[0].arn, null)
}

output "jenkins_url" {
  description = "Public Jenkins URL exposed through the ALB"
  value       = local.has_certificate ? "https://${aws_lb.jenkins.dns_name}" : "http://${aws_lb.jenkins.dns_name}"
}
