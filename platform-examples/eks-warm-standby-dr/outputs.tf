output "primary_cluster_name" {
  value       = module.primary.cluster_name
  description = "Primary Region EKS cluster name"
}

output "standby_cluster_name" {
  value       = module.standby.cluster_name
  description = "Standby Region EKS cluster name"
}

output "primary_region" {
  value       = var.primary_region
  description = "Primary Region"
}

output "standby_region" {
  value       = var.standby_region
  description = "Standby Region"
}
