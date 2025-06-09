locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Environment = var.environment
    Project     = "Jenkins-AWS"
    ManagedBy   = "Terraform"
    Owner       = "DevOps-Team"
  }
}

resource "aws_lb_target_group" "dev_proj_1_lb_target_group" {
  name     = var.lb_target_group_name
  port     = var.lb_target_group_port
  protocol = var.lb_target_group_protocol
  vpc_id   = var.vpc_id

  # Enhanced health check configuration
  health_check {
    path                = "/login"
    port                = var.lb_target_group_port
    protocol            = var.health_check_protocol
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  # Enable stickiness for better session handling
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400  # 24 hours
    enabled         = true
  }

  # Target group attributes
  deregistration_delay = 300  # 5 minutes
  slow_start = 30   # Gradually increase traffic to new targets
  
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-jenkins-target-group"
      Service = "Jenkins"
      Protocol = "HTTPS"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group_attachment" "dev_proj_1_lb_target_group_attachment" {
  target_group_arn = aws_lb_target_group.dev_proj_1_lb_target_group.arn
  target_id        = var.ec2_instance_id
  port             = var.lb_target_group_port
}

/*
# Add HTTPS listener - Commented out until load balancer is configured
resource "aws_lb_listener" "https" {
  load_balancer_arn = var.load_balancer_arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"  # Modern TLS policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_proj_1_lb_target_group.arn
  }
}

# HTTP to HTTPS redirect
resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = var.load_balancer_arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
*/