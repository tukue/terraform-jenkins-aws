locals {
  environment = "dev"
}

module "jenkins_platform" {
  source = "../../platform-modules/jenkins-platform"

  environment              = local.environment
  aws_region               = var.aws_region
  aws_account_id           = var.aws_account_id
  owner                    = "platform-team"
  project_name             = "Jenkins-AWS"
  instance_type            = "t3.small"
  vpc_cidr                 = "10.10.0.0/16"
  vpc_name                 = "jenkins-dev-vpc"
  cidr_public_subnet       = ["10.10.1.0/24", "10.10.2.0/24"]
  cidr_private_subnet      = ["10.10.11.0/24", "10.10.12.0/24"]
  eu_availability_zone     = ["eu-north-1a", "eu-north-1b"]
  public_key               = var.public_key
  run_ansible              = false
  enable_observability     = false
  enable_grafana_service   = false
  grafana_admin_password   = var.grafana_admin_password
  allowed_alb_cidr_blocks  = []
  enable_vault_integration = false

  tags = merge(var.tags, {
    CostCenter = "engineering-dev"
    Purpose    = "jenkins-development"
  })
}
