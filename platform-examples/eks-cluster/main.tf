module "eks" {
  source = "../../platform-modules/eks-cluster"

  cluster_name           = var.cluster_name
  environment            = var.environment
  aws_region             = var.aws_region
  aws_account_id         = var.aws_account_id
  kubernetes_version     = var.kubernetes_version
  endpoint_public_access = var.endpoint_public_access
  enable_lb_controller   = var.enable_lb_controller
  tags                   = var.tags

  node_groups = {
    general = {
      instance_types = var.environment == "prod" ? ["t3.medium", "t3.large"] : ["t3.medium"]
      min_size       = var.environment == "prod" ? 2 : 1
      max_size       = var.environment == "prod" ? 6 : 3
      desired_size   = var.environment == "prod" ? 2 : 1
      disk_size      = 20
      capacity_type  = var.environment == "prod" ? "ON_DEMAND" : "SPOT"
    }
  }
}
