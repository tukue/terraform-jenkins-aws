output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_arn" {
  value = module.eks.cluster_arn
}

output "cluster_version" {
  value = module.eks.cluster_version
}

output "cluster_iam_role_arn" {
  value = module.eks.cluster_iam_role_arn
}

output "authentication_mode" {
  value = module.eks.authentication_mode
}

output "node_group_roles" {
  value = module.eks.node_group_roles
}

output "node_group_statuses" {
  value = module.eks.node_group_statuses
}

output "oidc_provider_url" {
  value = module.eks.oidc_provider_url
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "lb_controller_role_arn" {
  value = module.eks.lb_controller_role_arn
}

output "aws_region" {
  value = module.eks.aws_region
}

output "aws_account_id" {
  value = module.eks.aws_account_id
}

output "vpc_id" {
  value = module.eks.vpc_id
}

output "node_instance_role_arn" {
  value = module.eks.node_instance_role_arn
}

output "kms_key_arn" {
  value = module.eks.kms_key_arn
}

output "access_entry_arns" {
  value = module.eks.access_entry_arns
}

output "kubeconfig" {
  value     = module.eks.kubeconfig
  sensitive = true
}
