output "eks_cluster_name" {
  description = "Name of the provisioned application cluster"
  value       = aws_eks_cluster.platform.name
}

output "ecr_repository_url" {
  description = "ECR repository used by application deployments"
  value       = aws_ecr_repository.applications.repository_url
}

output "aws_region" {
  description = "AWS region hosting the platform"
  value       = "eu-north-1"
}
