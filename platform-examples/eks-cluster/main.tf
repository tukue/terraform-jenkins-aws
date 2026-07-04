module "eks" {
  source = "../../platform-modules/eks-cluster"

  cluster_name                                = var.cluster_name
  environment                                 = var.environment
  aws_region                                  = var.aws_region
  aws_account_id                              = var.aws_account_id
  kubernetes_version                          = var.kubernetes_version
  authentication_mode                         = var.authentication_mode
  bootstrap_cluster_creator_admin_permissions = var.bootstrap_cluster_creator_admin_permissions
  endpoint_private_access                     = var.endpoint_private_access
  endpoint_public_access                      = var.endpoint_public_access
  endpoint_public_access_cidrs                = var.endpoint_public_access_cidrs
  enable_lb_controller                        = var.enable_lb_controller
  tags                                        = var.tags

  access_entries             = var.access_entries
  access_policy_associations = var.access_policy_associations

  cluster_addons = {
    vpc-cni            = {}
    coredns            = {}
    kube-proxy         = {}
    pod-identity-agent = {}
  }

  node_groups = {
    system = {
      instance_types = var.environment == "prod" ? ["t3.medium", "t3.large"] : ["t3.medium"]
      min_size       = 1
      max_size       = var.environment == "prod" ? 4 : 3
      desired_size   = 1
      disk_size      = 20
      ami_type       = "AL2023_x86_64_STANDARD"
      capacity_type  = var.environment == "prod" ? "ON_DEMAND" : "SPOT"
      labels = {
        "node-role.kubernetes.io/system" = ""
      }
      taints = var.environment == "prod" ? [
        {
          key    = "CriticalAddonsOnly"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      ] : []
    }
    application = {
      instance_types = var.environment == "prod" ? ["t3.large", "m5.large"] : ["t3.medium"]
      min_size       = var.environment == "prod" ? 2 : 1
      max_size       = var.environment == "prod" ? 10 : 5
      desired_size   = var.environment == "prod" ? 2 : 1
      disk_size      = 50
      ami_type       = "AL2023_x86_64_STANDARD"
      capacity_type  = var.environment == "prod" ? "ON_DEMAND" : "SPOT"
      labels = {
        "node-role.kubernetes.io/application" = ""
      }
    }
  }
}
