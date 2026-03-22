output "customer_url" {
  value = module.customer_runtime.customer_url
}

output "alb_dns_name" {
  value = module.customer_runtime.alb_dns_name
}

output "cluster_name" {
  value = module.customer_runtime.cluster_name
}

output "aws_region" {
  value = module.customer_runtime.aws_region
}

output "aws_account_id" {
  value = module.customer_runtime.aws_account_id
}

output "tenant_name" {
  value = module.customer_runtime.tenant_name
}

output "network_profile" {
  value = module.customer_runtime.network_profile
}

output "resolved_vpc_id" {
  value = module.customer_runtime.resolved_vpc_id
}
