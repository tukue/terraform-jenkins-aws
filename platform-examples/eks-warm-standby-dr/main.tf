locals {
  common_tags = merge(var.tags, {
    Architecture = "WarmStandbyDR"
    Portfolio    = "true"
  })

  node_groups = {
    system = {
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 2
      desired_size   = 1
      disk_size      = 20
      ami_type       = "AL2023_x86_64_STANDARD"
      capacity_type  = "SPOT"
    }
    application = {
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 2
      desired_size   = 1
      disk_size      = 30
      ami_type       = "AL2023_x86_64_STANDARD"
      capacity_type  = "SPOT"
    }
  }
}

module "primary" {
  source = "../../platform-modules/eks-cluster"

  providers = {
    aws = aws.primary
  }

  cluster_name           = "${var.cluster_name}-primary"
  environment            = var.environment
  aws_region             = var.primary_region
  aws_account_id         = var.aws_account_id
  kubernetes_version     = var.kubernetes_version
  endpoint_public_access = false
  enable_lb_controller   = true
  cluster_addons = {
    vpc-cni    = {}
    coredns    = {}
    kube-proxy = {}
  }
  node_groups = local.node_groups
  tags        = merge(local.common_tags, { RegionRole = "primary" })
}

module "standby" {
  source = "../../platform-modules/eks-cluster"

  providers = {
    aws = aws.standby
  }

  cluster_name           = "${var.cluster_name}-standby"
  environment            = var.environment
  aws_region             = var.standby_region
  aws_account_id         = var.aws_account_id
  kubernetes_version     = var.kubernetes_version
  endpoint_public_access = false
  enable_lb_controller   = true
  cluster_addons = {
    vpc-cni    = {}
    coredns    = {}
    kube-proxy = {}
  }
  node_groups = local.node_groups
  tags        = merge(local.common_tags, { RegionRole = "standby" })
}
