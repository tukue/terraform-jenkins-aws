locals {
  tenant_label        = trimspace(var.tenant_name) != "" ? var.tenant_name : var.customer_name
  name_prefix         = lower("${local.tenant_label}-${var.environment}")
  cluster_name        = "${local.name_prefix}-ecs"
  service_name        = "${local.name_prefix}-service"
  alb_name            = substr("${local.name_prefix}-alb", 0, 32)
  tg_name             = substr("${local.name_prefix}-tg", 0, 32)
  log_group_name      = "/ecs/${local.name_prefix}"
  exec_log_group_name = "/ecs/exec/${local.name_prefix}"
  alb_subnet_ids      = var.alb_internal ? local.resolved_private_subnet_ids : local.resolved_public_subnet_ids

  resolved_vpc_id             = var.vpc_id != "" ? var.vpc_id : data.aws_ssm_parameter.vpc_id[0].value
  resolved_public_subnet_ids  = length(var.public_subnet_ids) > 0 ? var.public_subnet_ids : split(",", data.aws_ssm_parameter.public_subnet_ids[0].value)
  resolved_private_subnet_ids = length(var.private_subnet_ids) > 0 ? var.private_subnet_ids : split(",", data.aws_ssm_parameter.private_subnet_ids[0].value)
  ecr_repository_name         = trimspace(var.ecr_repository_name) != "" ? var.ecr_repository_name : "${local.name_prefix}-ecr"

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
          awslogs-region        = var.aws_region
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

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"

      log_configuration {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.exec.name
      }
    }
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "customer" {
  name              = local.log_group_name
  retention_in_days = 30
  tags              = local.common_tags
}

resource "aws_cloudwatch_log_group" "exec" {
  name              = local.exec_log_group_name
  retention_in_days = 30
  tags              = local.common_tags
}

resource "aws_ecr_repository" "customer" {
  count = var.create_ecr_repository ? 1 : 0

  name                 = local.ecr_repository_name
  image_tag_mutability = var.ecr_image_tag_mutability

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = local.common_tags
}

resource "aws_ecr_lifecycle_policy" "customer" {
  count      = var.create_ecr_repository ? 1 : 0
  repository = aws_ecr_repository.customer[0].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire old images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 20
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
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

  dynamic "ingress" {
    for_each = var.alb_ingress_cidr_blocks

    content {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  dynamic "ingress" {
    for_each = var.alb_ingress_cidr_blocks

    content {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
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
  subnets            = local.alb_subnet_ids
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
    type = var.alb_certificate_arn != "" && var.redirect_http_to_https ? "redirect" : "forward"

    dynamic "redirect" {
      for_each = var.alb_certificate_arn != "" && var.redirect_http_to_https ? [1] : []

      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    target_group_arn = var.alb_certificate_arn != "" && var.redirect_http_to_https ? null : aws_lb_target_group.customer.arn
  }
}

resource "aws_lb_listener" "https" {
  count             = var.alb_certificate_arn == "" ? 0 : 1
  load_balancer_arn = aws_lb.customer.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.alb_certificate_arn
  ssl_policy        = var.alb_ssl_policy

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
  name                               = local.service_name
  cluster                            = aws_ecs_cluster.customer.id
  task_definition                    = aws_ecs_task_definition.customer.arn
  desired_count                      = var.desired_count
  launch_type                        = "FARGATE"
  enable_execute_command             = var.enable_execute_command
  platform_version                   = "LATEST"
  enable_ecs_managed_tags            = true
  propagate_tags                     = "SERVICE"
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

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
    aws_lb_listener.http
  ]

  lifecycle {
    precondition {
      condition     = !var.enable_autoscaling || var.autoscaling_max_capacity >= var.autoscaling_min_capacity
      error_message = "autoscaling_max_capacity must be greater than or equal to autoscaling_min_capacity."
    }

    precondition {
      condition     = !var.enable_autoscaling || (var.desired_count >= var.autoscaling_min_capacity && var.desired_count <= var.autoscaling_max_capacity)
      error_message = "desired_count must stay within the autoscaling min/max range when autoscaling is enabled."
    }
  }

  tags = local.common_tags
}

resource "aws_appautoscaling_target" "customer" {
  count = var.enable_autoscaling ? 1 : 0

  max_capacity       = var.autoscaling_max_capacity
  min_capacity       = var.autoscaling_min_capacity
  resource_id        = "service/${aws_ecs_cluster.customer.name}/${aws_ecs_service.customer.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [aws_ecs_service.customer]
}

resource "aws_appautoscaling_policy" "cpu" {
  count = var.enable_autoscaling ? 1 : 0

  name               = "${local.name_prefix}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.customer[0].resource_id
  scalable_dimension = aws_appautoscaling_target.customer[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.customer[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = var.autoscaling_cpu_target
    scale_in_cooldown  = var.autoscaling_scale_in_cooldown
    scale_out_cooldown = var.autoscaling_scale_out_cooldown
  }
}

resource "aws_appautoscaling_policy" "memory" {
  count = var.enable_autoscaling ? 1 : 0

  name               = "${local.name_prefix}-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.customer[0].resource_id
  scalable_dimension = aws_appautoscaling_target.customer[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.customer[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = var.autoscaling_memory_target
    scale_in_cooldown  = var.autoscaling_scale_in_cooldown
    scale_out_cooldown = var.autoscaling_scale_out_cooldown
  }
}

resource "aws_appautoscaling_policy" "alb_requests" {
  count = var.enable_autoscaling ? 1 : 0

  name               = "${local.name_prefix}-request-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.customer[0].resource_id
  scalable_dimension = aws_appautoscaling_target.customer[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.customer[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${aws_lb.customer.arn_suffix}/${aws_lb_target_group.customer.arn_suffix}"
    }

    target_value       = var.autoscaling_request_target
    scale_in_cooldown  = var.autoscaling_scale_in_cooldown
    scale_out_cooldown = var.autoscaling_scale_out_cooldown
  }
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
