locals {
  tier_configs = {
    small = { cpu = 256, memory = 512,  desired = 1, waf = 1000 }
    med   = { cpu = 512, memory = 1024, desired = 2, waf = 2000 }
    large = { cpu = 1024, memory = 2048, desired = 3, waf = 5000 }
  }
  config = local.tier_configs[var.tier]
  common_tags = merge(
    var.tags,
    {
      ServiceTier = var.tier
      ManagedBy   = "terraform-service-tier-wrapper"
      Platform    = "ecs-service-tier-wrapper"
    }
  )
}

module "ecs_runtime" {
  source             = "../customer-ecs-runtime"
  customer_name      = var.service_name
  tenant_name        = var.tenant_name
  environment        = var.environment
  aws_region         = var.aws_region
  aws_account_id     = var.aws_account_id
  network_profile    = var.network_profile
  vpc_id             = var.vpc_id
  public_subnet_ids  = var.public_subnet_ids
  private_subnet_ids = var.private_subnet_ids
  container_image    = var.container_image
  container_port     = var.container_port
  cpu                = local.config.cpu
  memory             = local.config.memory
  desired_count      = local.config.desired
  health_check_path  = var.health_check_path
  hosted_zone_id     = var.hosted_zone_id
  dns_name           = var.dns_name
  tenant_domain      = var.tenant_domain
  task_environment   = var.task_environment
  task_secrets       = var.task_secrets
  enable_waf         = true
  waf_rate_limit     = local.config.waf
  tags               = local.common_tags
}
