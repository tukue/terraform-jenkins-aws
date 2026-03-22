locals {
  tenant_label   = trimspace(var.tenant_name) != "" ? var.tenant_name : var.customer_name
  name_prefix    = lower("${local.tenant_label}-${var.environment}")
  cluster_name   = "${local.name_prefix}-ecs"
  service_name   = "${local.name_prefix}-service"
  alb_name       = substr("${local.name_prefix}-alb", 0, 32)
  tg_name        = substr("${local.name_prefix}-tg", 0, 32)
  log_group_name = "/ecs/${local.name_prefix}"

  resolved_vpc_id             = var.vpc_id != "" ? var.vpc_id : data.aws_ssm_parameter.vpc_id[0].value
  resolved_public_subnet_ids  = length(var.public_subnet_ids) > 0 ? var.public_subnet_ids : split(",", data.aws_ssm_parameter.public_subnet_ids[0].value)
  resolved_private_subnet_ids = length(var.private_subnet_ids) > 0 ? var.private_subnet_ids : split(",", data.aws_ssm_parameter.private_subnet_ids[0].value)

  common_tags = merge(
    var.tags,
    {
      Customer       = var.customer_name
      Tenant         = local.tenant_label
      TenantDomain   = var.tenant_domain
      Environment    = var.environment
      AWSRegion      = var.aws_region
      AWSAccount     = var.aws_account_id
      NetworkProfile = var.network_profile
      ManagedBy      = "terraform"
      Platform       = "ecs-customer-runtime"
    }
  )

  container_definitions = [
    {
      name      = "app"
      image     = var.container_image
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      environment = [
        for key, value in var.task_environment : {
          name  = key
          value = value
        }
      ]
      secrets = [
        for key, value in var.task_secrets : {
          name      = key
          valueFrom = value
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.customer.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "app"
        }
      }
    }
  ]
}

data "aws_ssm_parameter" "vpc_id" {
  count = var.vpc_id == "" ? 1 : 0
  name  = "/platform/${var.aws_region}/${var.network_profile}/vpc-id"
}

data "aws_ssm_parameter" "public_subnet_ids" {
  count = length(var.public_subnet_ids) == 0 ? 1 : 0
  name  = "/platform/${var.aws_region}/${var.network_profile}/public-subnet-ids"
}

data "aws_ssm_parameter" "private_subnet_ids" {
  count = length(var.private_subnet_ids) == 0 ? 1 : 0
  name  = "/platform/${var.aws_region}/${var.network_profile}/private-subnet-ids"
}

data "aws_region" "current" {}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_ecs_cluster" "customer" {
  name = local.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "customer" {
  name              = local.log_group_name
  retention_in_days = 30
  tags              = local.common_tags
}

resource "aws_iam_role" "task_execution" {
  name               = "${local.name_prefix}-ecs-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy_attachment" "task_execution" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task" {
  name               = "${local.name_prefix}-ecs-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
  tags               = local.common_tags
}

resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Security group for customer ALB"
  vpc_id      = local.resolved_vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_security_group" "service" {
  name        = "${local.name_prefix}-service-sg"
  description = "Security group for customer ECS tasks"
  vpc_id      = local.resolved_vpc_id

  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_lb" "customer" {
  name               = local.alb_name
  internal           = var.alb_internal
  load_balancer_type = "application"
  subnets            = local.resolved_public_subnet_ids
  security_groups    = [aws_security_group.alb.id]

  tags = local.common_tags
}

resource "aws_wafv2_web_acl" "customer" {
  count = var.enable_waf ? 1 : 0

  name  = "${local.name_prefix}-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.name_prefix}-waf"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

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
      metric_name                = "${local.name_prefix}-common"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2

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
      metric_name                = "${local.name_prefix}-bad-inputs"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.name_prefix}-sqli"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "RateLimit"
    priority = 4

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = var.waf_rate_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.name_prefix}-rate-limit"
      sampled_requests_enabled   = true
    }
  }

  tags = local.common_tags
}

resource "aws_wafv2_web_acl_association" "customer" {
  count = var.enable_waf ? 1 : 0

  resource_arn = aws_lb.customer.arn
  web_acl_arn  = aws_wafv2_web_acl.customer[0].arn
}

resource "aws_lb_target_group" "customer" {
  name        = local.tg_name
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = local.resolved_vpc_id

  health_check {
    enabled             = true
    path                = var.health_check_path
    protocol            = "HTTP"
    matcher             = "200-399"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
  }

  tags = local.common_tags
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.customer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.customer.arn
  }
}

resource "aws_lb_listener" "https" {
  count             = var.alb_certificate_arn == "" ? 0 : 1
  load_balancer_arn = aws_lb.customer.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.alb_certificate_arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.customer.arn
  }
}

resource "aws_ecs_task_definition" "customer" {
  family                   = "${local.name_prefix}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = tostring(var.cpu)
  memory                   = tostring(var.memory)
  execution_role_arn       = aws_iam_role.task_execution.arn
  task_role_arn            = aws_iam_role.task.arn
  container_definitions    = jsonencode(local.container_definitions)

  tags = local.common_tags
}

resource "aws_ecs_service" "customer" {
  name                   = local.service_name
  cluster                = aws_ecs_cluster.customer.id
  task_definition        = aws_ecs_task_definition.customer.arn
  desired_count          = var.desired_count
  launch_type            = "FARGATE"
  enable_execute_command = var.enable_execute_command
  platform_version       = "LATEST"

  network_configuration {
    subnets          = local.resolved_private_subnet_ids
    security_groups  = [aws_security_group.service.id]
    assign_public_ip = var.assign_public_ip
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.customer.arn
    container_name   = "app"
    container_port   = var.container_port
  }

  depends_on = [
    aws_lb_listener.http,
    aws_wafv2_web_acl_association.customer
  ]

  tags = local.common_tags
}

resource "aws_route53_record" "customer" {
  count   = var.hosted_zone_id == "" || (var.dns_name == "" && var.tenant_domain == "") ? 0 : 1
  zone_id = var.hosted_zone_id
  name    = var.dns_name != "" ? var.dns_name : var.tenant_domain
  type    = "A"

  alias {
    name                   = aws_lb.customer.dns_name
    zone_id                = aws_lb.customer.zone_id
    evaluate_target_health = true
  }
}
