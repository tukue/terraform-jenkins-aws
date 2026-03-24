output "cluster_name" {
  value       = aws_ecs_cluster.customer.name
  description = "ECS cluster name"
}

output "cluster_arn" {
  value       = aws_ecs_cluster.customer.arn
  description = "ECS cluster ARN"
}

output "service_name" {
  value       = aws_ecs_service.customer.name
  description = "ECS service name"
}

output "service_arn" {
  value       = aws_ecs_service.customer.id
  description = "ECS service ARN"
}

output "alb_dns_name" {
  value       = aws_lb.customer.dns_name
  description = "Application Load Balancer DNS name"
}

output "alb_zone_id" {
  value       = aws_lb.customer.zone_id
  description = "Application Load Balancer hosted zone ID"
}

output "service_security_group_id" {
  value       = aws_security_group.service.id
  description = "Security group used by the ECS service"
}

output "customer_url" {
  value       = var.dns_name != "" && var.alb_certificate_arn != "" ? "https://${var.dns_name}" : "http://${aws_lb.customer.dns_name}"
  description = "Customer runtime URL"
}

output "waf_web_acl_arn" {
  value       = try(aws_wafv2_web_acl.customer[0].arn, null)
  description = "WAF web ACL ARN attached to the ALB"
}

output "aws_region" {
  value       = var.aws_region
  description = "AWS region where the customer runtime is provisioned"
}

output "aws_account_id" {
  value       = var.aws_account_id
  description = "AWS account ID for the customer runtime"
}

output "tenant_name" {
  value       = local.tenant_label
  description = "Tenant name used for naming and tagging"
}

output "network_profile" {
  value       = var.network_profile
  description = "Regional landing zone profile"
}

output "resolved_vpc_id" {
  value       = local.resolved_vpc_id
  description = "Resolved VPC ID used by the runtime"
}

output "resolved_public_subnet_ids" {
  value       = local.resolved_public_subnet_ids
  description = "Resolved public subnet IDs used by the ALB"
}

output "resolved_private_subnet_ids" {
  value       = local.resolved_private_subnet_ids
  description = "Resolved private subnet IDs used by ECS tasks"
}

output "ecr_repository_name" {
  value       = try(aws_ecr_repository.customer[0].name, local.ecr_repository_name)
  description = "ECR repository name for the customer runtime image"
}

output "ecr_repository_url" {
  value       = try(aws_ecr_repository.customer[0].repository_url, null)
  description = "ECR repository URL for the customer runtime image"
}
