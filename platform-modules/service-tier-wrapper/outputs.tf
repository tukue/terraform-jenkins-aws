output "service_tier" {
  value       = var.tier
  description = "Selected service tier preset"
}

output "sizing_summary" {
  value = {
    cpu               = local.config.cpu
    memory            = local.config.memory
    desired_count     = local.config.desired
    waf_rate_limit    = local.config.waf
    container_port    = var.container_port
    health_check_path = var.health_check_path
  }
  description = "Derived service sizing and operational defaults from the selected tier"
}

output "cluster_name" {
  value       = module.ecs_runtime.cluster_name
  description = "ECS cluster name created by the wrapped runtime module"
}

output "service_name" {
  value       = module.ecs_runtime.service_name
  description = "ECS service name created by the wrapped runtime module"
}

output "customer_url" {
  value       = module.ecs_runtime.customer_url
  description = "Primary URL for the deployed service"
}

output "alb_dns_name" {
  value       = module.ecs_runtime.alb_dns_name
  description = "Application Load Balancer DNS name"
}

output "resolved_vpc_id" {
  value       = module.ecs_runtime.resolved_vpc_id
  description = "Resolved VPC ID used by the wrapped runtime"
}

output "resolved_public_subnet_ids" {
  value       = module.ecs_runtime.resolved_public_subnet_ids
  description = "Resolved public subnet IDs used by the wrapped runtime"
}

output "resolved_private_subnet_ids" {
  value       = module.ecs_runtime.resolved_private_subnet_ids
  description = "Resolved private subnet IDs used by the wrapped runtime"
}

output "ecr_repository_name" {
  value       = module.ecs_runtime.ecr_repository_name
  description = "ECR repository name for the wrapped service"
}
