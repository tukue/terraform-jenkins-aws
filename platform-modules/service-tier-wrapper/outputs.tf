output "service_tier" {
  value       = var.tier
  description = "Selected service tier preset"
}

output "product_contract" {
  value = {
    module_surface = "service-tier-wrapper"
    consumption_model = "opinionated"
    service_name = var.service_name
    tenant_name  = var.tenant_name != "" ? var.tenant_name : var.service_name
    environment  = var.environment
    aws_region   = var.aws_region
    network_profile = var.network_profile
    dns_enabled  = var.dns_name != ""
  }
  description = "High-level product contract for callers, docs, and automation layers"
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

output "runtime_contract" {
  value = {
    container_image         = var.container_image
    container_port          = var.container_port
    health_check_path       = var.health_check_path
    hosted_zone_id_supplied = var.hosted_zone_id != ""
    dns_name                = var.dns_name
    task_environment_keys   = sort(keys(var.task_environment))
    task_secret_keys        = sort(keys(var.task_secrets))
  }
  description = "Runtime inputs that remain configurable at the wrapper layer"
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

output "deployment_summary" {
  value = {
    service_tier                = var.tier
    cluster_name                = module.ecs_runtime.cluster_name
    service_name                = module.ecs_runtime.service_name
    customer_url                = module.ecs_runtime.customer_url
    alb_dns_name                = module.ecs_runtime.alb_dns_name
    resolved_vpc_id             = module.ecs_runtime.resolved_vpc_id
    resolved_public_subnet_ids  = module.ecs_runtime.resolved_public_subnet_ids
    resolved_private_subnet_ids = module.ecs_runtime.resolved_private_subnet_ids
    ecr_repository_name         = module.ecs_runtime.ecr_repository_name
  }
  description = "Consumer-oriented deployment summary for automation and handoff flows"
}
