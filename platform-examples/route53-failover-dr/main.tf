locals {
  endpoints = {
    primary = var.primary_endpoint
    standby = var.standby_endpoint
  }
}

resource "aws_route53_health_check" "regional" {
  for_each = local.endpoints

  fqdn              = each.value.record_name
  port              = var.health_check_port
  type              = "HTTPS"
  resource_path     = var.health_check_path
  request_interval  = 30
  failure_threshold = 3
  measure_latency   = true
  enable_sni        = true

  tags = {
    Name       = "${var.record_name}-${each.key}"
    ManagedBy  = "Terraform"
    Component  = "regional-failover"
    RegionRole = each.key
  }
}

resource "aws_route53_record" "regional_endpoint" {
  for_each = local.endpoints

  zone_id = var.hosted_zone_id
  name    = each.value.record_name
  type    = "A"

  alias {
    name                   = each.value.dns_name
    zone_id                = each.value.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "regional_failover" {
  for_each = local.endpoints

  zone_id         = var.hosted_zone_id
  name            = var.record_name
  type            = "A"
  set_identifier  = each.key
  health_check_id = aws_route53_health_check.regional[each.key].id

  failover_routing_policy {
    type = each.key == "primary" ? "PRIMARY" : "SECONDARY"
  }

  alias {
    name                   = each.value.dns_name
    zone_id                = each.value.zone_id
    evaluate_target_health = true
  }
}
