aws_region                                  = "eu-north-1"
aws_account_id                              = "123456789012"
cluster_name                                = "my-platform"
environment                                 = "dev"
kubernetes_version                          = "1.31"
authentication_mode                         = "API_AND_CONFIG_MAP"
bootstrap_cluster_creator_admin_permissions = true
enable_lb_controller                        = true
endpoint_private_access                     = true
endpoint_public_access                      = true
endpoint_public_access_cidrs                = ["203.0.113.0/24"]

access_entries = {
  platform-admin = {
    principal_arn     = "arn:aws:iam::123456789012:role/Admin"
    kubernetes_groups = ["system:masters"]
    type              = "STANDARD"
  }
  ci-role = {
    principal_arn     = "arn:aws:iam::123456789012:role/CI"
    kubernetes_groups = ["ci-deployers"]
  }
}

access_policy_associations = {
  ci-eks-admin = {
    principal_arn     = "arn:aws:iam::123456789012:role/CI"
    policy_arn        = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
    access_scope_type = "cluster"
  }
}

tags = {
  Environment = "dev"
  Owner       = "platform-team"
  Tier        = "nonprod"
}
