locals {
  has_certificate = trimspace(var.certificate_arn) != ""
}

resource "aws_lb" "jenkins" {
  name               = "${var.name_prefix}-alb"
  #tfsec:ignore:aws-elb-alb-not-public Public ALB is the intentional WAF-protected entry point; Jenkins itself remains private.
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  drop_invalid_header_fields = true
  enable_deletion_protection = false

  tags = merge(
    var.tags,
    {
      Name    = "${var.name_prefix}-alb"
      Service = "Jenkins"
    }
  )
}

resource "aws_lb_target_group" "jenkins" {
  name     = "${var.name_prefix}-tg"
  port     = var.jenkins_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 30
    matcher             = "200-399"
    path                = "/login"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  stickiness {
    cookie_duration = 86400
    enabled         = true
    type            = "lb_cookie"
  }

  tags = merge(
    var.tags,
    {
      Name    = "${var.name_prefix}-tg"
      Service = "Jenkins"
    }
  )
}

resource "aws_lb_target_group_attachment" "jenkins" {
  target_group_arn = aws_lb_target_group.jenkins.arn
  target_id        = var.jenkins_instance_id
  port             = var.jenkins_port
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.jenkins.arn
  port              = 80
  #tfsec:ignore:aws-elb-http-not-used HTTP is used only as the public redirect listener when alb_certificate_arn enables HTTPS.
  protocol          = "HTTP"

  default_action {
    type             = local.has_certificate ? "redirect" : "forward"
    target_group_arn = local.has_certificate ? null : aws_lb_target_group.jenkins.arn

    dynamic "redirect" {
      for_each = local.has_certificate ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  tags = var.tags
}

resource "aws_lb_listener" "https" {
  count = local.has_certificate ? 1 : 0

  load_balancer_arn = aws_lb.jenkins.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins.arn
  }

  tags = var.tags
}

resource "aws_wafv2_web_acl" "jenkins" {
  count = var.enable_waf ? 1 : 0

  name  = "${var.name_prefix}-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 10

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name_prefix}-common"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 20

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name_prefix}-bad-inputs"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "RateLimitByIp"
    priority = 30

    action {
      block {}
    }

    statement {
      rate_based_statement {
        aggregate_key_type = "IP"
        limit              = var.waf_rate_limit
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name_prefix}-rate-limit"
      sampled_requests_enabled   = true
    }
  }

  tags = merge(
    var.tags,
    {
      Name    = "${var.name_prefix}-waf"
      Service = "Jenkins"
    }
  )

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name_prefix}-waf"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "jenkins" {
  count = var.enable_waf ? 1 : 0

  resource_arn = aws_lb.jenkins.arn
  web_acl_arn  = aws_wafv2_web_acl.jenkins[0].arn
}
