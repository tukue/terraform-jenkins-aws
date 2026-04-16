module "service" {
  source = "../../platform-modules/service-tier-wrapper"

  service_name    = var.service_name
  environment     = var.environment
  tier            = var.tier
  container_image = var.container_image
  aws_region      = var.aws_region
  aws_account_id  = var.aws_account_id
  network_profile = var.network_profile
  dns_name        = var.dns_name
  hosted_zone_id  = var.hosted_zone_id
  task_environment = var.task_environment
  task_secrets     = var.task_secrets
  tags             = var.tags
}
