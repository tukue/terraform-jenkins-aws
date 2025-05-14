locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Environment = var.environment
    Project     = "Jenkins-AWS"
    ManagedBy   = "Terraform"
    Owner       = "DevOps-Team"
  }
}

data "aws_route53_zone" "dev_proj_1_jhooq_org" {
  name         = "jhooq.org"
  private_zone = false
}

resource "aws_route53_record" "lb_record" {
  zone_id = data.aws_route53_zone.dev_proj_1_jhooq_org.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.aws_lb_dns_name
    zone_id                = var.aws_lb_zone_id
    evaluate_target_health = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-dns-record"
      Service = "Jenkins"
    }
  )
}