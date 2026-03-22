module "customer_runtime" {
  source = "../../platform-modules/customer-ecs-runtime"

  customer_name              = var.customer_name
  tenant_name                = var.tenant_name
  environment                = var.environment
  aws_region                 = var.aws_region
  aws_account_id             = var.aws_account_id
  container_image            = var.container_image
  container_port             = var.container_port
  desired_count              = var.desired_count
  enable_autoscaling         = var.enable_autoscaling
  autoscaling_min_capacity   = var.autoscaling_min_capacity
  autoscaling_max_capacity   = var.autoscaling_max_capacity
  autoscaling_cpu_target     = var.autoscaling_cpu_target
  autoscaling_memory_target  = var.autoscaling_memory_target
  autoscaling_request_target = var.autoscaling_request_target
  cpu                        = var.cpu
  memory                     = var.memory
  alb_certificate_arn        = var.alb_certificate_arn
  redirect_http_to_https     = var.redirect_http_to_https
  alb_ingress_cidr_blocks    = var.alb_ingress_cidr_blocks
  hosted_zone_id             = var.hosted_zone_id
  dns_name                   = var.dns_name
  enable_waf                 = var.enable_waf
  waf_rate_limit             = var.waf_rate_limit
  tags                       = var.tags
}
