output "cluster_name" {
  value       = aws_eks_cluster.this.name
  description = "EKS cluster name"
}

output "cluster_arn" {
  value       = aws_eks_cluster.this.arn
  description = "EKS cluster ARN"
}

output "cluster_version" {
  value       = aws_eks_cluster.this.version
  description = "EKS cluster Kubernetes version"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.this.endpoint
  description = "EKS cluster API server endpoint"
}

output "cluster_certificate_authority" {
  value       = aws_eks_cluster.this.certificate_authority[0].data
  description = "EKS cluster certificate authority data"
}

output "cluster_security_group_id" {
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  description = "Security group ID attached to the EKS cluster control plane"
}

output "cluster_iam_role_arn" {
  value       = aws_iam_role.cluster.arn
  description = "IAM role ARN for the EKS cluster"
}

output "authentication_mode" {
  value       = aws_eks_cluster.this.access_config[0].authentication_mode
  description = "Authentication mode for the EKS cluster"
}

output "oidc_provider_arn" {
  value       = var.create_oidc_provider ? aws_iam_openid_connect_provider.this[0].arn : null
  description = "IAM OIDC provider ARN for the EKS cluster"
}

output "oidc_provider_url" {
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
  description = "OIDC issuer URL for the EKS cluster"
}

output "oidc_provider_thumbprint" {
  value       = data.tls_certificate.this.certificates[0].sha1_fingerprint
  description = "Thumbprint of the OIDC provider certificate"
}

output "node_group_roles" {
  value = {
    for name, ng in aws_eks_node_group.this : name => ng.role_arn
  }
  description = "Map of node group names to their IAM role ARNs"
}

output "node_group_arns" {
  value = {
    for name, ng in aws_eks_node_group.this : name => ng.arn
  }
  description = "Map of node group names to their ARNs"
}

output "node_group_statuses" {
  value = {
    for name, ng in aws_eks_node_group.this : name => ng.status
  }
  description = "Map of node group names to their status"
}

output "irsa_role_arns" {
  value = {
    for k, role in aws_iam_role.irsa : k => role.arn
  }
  description = "Map of IRSA role names to their ARNs"
}

output "lb_controller_role_arn" {
  value       = var.enable_lb_controller ? aws_iam_role.lb_controller[0].arn : null
  description = "IAM role ARN for AWS Load Balancer Controller IRSA"
}

output "vpc_id" {
  value       = local.resolved_vpc_id
  description = "VPC ID used by the EKS cluster"
}

output "subnet_ids" {
  value       = local.resolved_subnet_ids
  description = "Subnet IDs used by the EKS cluster"
}

output "aws_region" {
  value       = var.aws_region
  description = "AWS region where the EKS cluster is provisioned"
}

output "aws_account_id" {
  value       = var.aws_account_id
  description = "AWS account ID for the EKS cluster"
}

output "environment" {
  value       = var.environment
  description = "Environment name"
}

output "network_profile" {
  value       = var.network_profile
  description = "Regional landing zone profile"
}

output "cloudwatch_log_group_name" {
  value       = var.enable_cluster_logging ? aws_cloudwatch_log_group.eks[0].name : null
  description = "CloudWatch log group name for EKS control plane logs"
}

output "node_instance_role_arn" {
  value       = aws_iam_role.node.arn
  description = "IAM role ARN used by EKS managed node groups"
}

output "kms_key_arn" {
  value       = var.cluster_encryption_config.enabled && var.cluster_encryption_config.kms_key_arn == "" ? aws_kms_key.eks[0].arn : var.cluster_encryption_config.kms_key_arn
  description = "KMS key ARN used for EKS cluster encryption"
}

output "access_entry_arns" {
  value = {
    for k, entry in aws_eks_access_entry.this : k => entry.arn
  }
  description = "Map of access entry ARNs"
}

output "kubeconfig" {
  sensitive = true
  value = {
    api_version = "v1"
    kind        = "Config"
    clusters = [{
      cluster = {
        server                     = aws_eks_cluster.this.endpoint
        certificate_authority_data = aws_eks_cluster.this.certificate_authority[0].data
      }
      name = aws_eks_cluster.this.name
    }]
    contexts = [{
      context = {
        cluster = aws_eks_cluster.this.name
        user    = aws_eks_cluster.this.name
      }
      name = aws_eks_cluster.this.name
    }]
    current_context = aws_eks_cluster.this.name
    users = [{
      name = aws_eks_cluster.this.name
      user = {
        exec = {
          api_version = "client.authentication.k8s.io/v1beta1"
          command     = "aws"
          args = [
            "eks", "get-token", "--cluster-name", aws_eks_cluster.this.name,
            "--region", var.aws_region
          ]
        }
      }
    }]
  }
  description = "Kubeconfig data for the EKS cluster using awscli token authentication"
}
